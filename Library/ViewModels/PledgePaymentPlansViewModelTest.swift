import Foundation
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentPlansViewModelTests: TestCase {
  // MARK: Properties

  private var vm: PledgePaymentPlansViewModelType = PledgePaymentPlansViewModel()

  private var reloadPaymentPlansPlanType = TestObserver<PledgePaymentPlansType, Never>()
  private var notifyDelegatePaymentPlanSelected = TestObserver<PledgePaymentPlansType, Never>()

  private let pledgeInFullIndexPath = IndexPath(
    row: 0,
    section: 0
  )
  private let pledgeOverTimeIndexPath = IndexPath(
    row: 0,
    section: 1
  )

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegatePaymentPlanSelected
      .observe(self.notifyDelegatePaymentPlanSelected.observer)

    self.vm.outputs.reloadPaymentPlans
      .map { $0.selectedPlan }
      .observe(self.reloadPaymentPlansPlanType.observer)
  }

  // MARK: Test cases

  func testPaymenPlans_DefaultState() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.reloadPaymentPlansPlanType.assertDidNotEmitValue()
      self.notifyDelegatePaymentPlanSelected.assertDidNotEmitValue()
    }
  }

  func testPaymenPlans_WithConfigureData() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      let data = PledgePaymentPlansAndSelectionData(selectedPlan: .pledgeInFull)

      self.vm.inputs.configure(with: data)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull])
      self.notifyDelegatePaymentPlanSelected.assertDidNotEmitValue()
    }
  }

  func testPaymenPlans_PledgeInFullSelected() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didSelectPlanType(.pledgeInFull)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull])
      self.notifyDelegatePaymentPlanSelected.assertValues([.pledgeInFull])
    }
  }

  func testPaymenPlans_PledgeOverTimeSelected() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didSelectPlanType(.pledgeOverTime)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeOverTime])
      self.notifyDelegatePaymentPlanSelected.assertValues([.pledgeOverTime])
    }
  }
}
