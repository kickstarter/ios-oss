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
    section: PledgePaymentPlansType.pledgeinFull.rawValue
  )
  private let pledgeOverTimeIndexPath = IndexPath(
    row: 0,
    section: PledgePaymentPlansType.pledgeOverTime.rawValue
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

      let data = PledgePaymentPlansAndSelectionData(selectedPlan: .pledgeinFull)

      self.vm.inputs.configure(with: data)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeinFull])
      self.notifyDelegatePaymentPlanSelected.assertDidNotEmitValue()
    }
  }

  func testPaymenPlans_PledgeInFullSelected() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didSelectRowAtIndexPath(self.pledgeInFullIndexPath)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeinFull])
      self.notifyDelegatePaymentPlanSelected.assertValues([.pledgeinFull])
    }
  }

  func testPaymenPlans_PledgeOverTimeSelected() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.didSelectRowAtIndexPath(self.pledgeOverTimeIndexPath)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeOverTime])
      self.notifyDelegatePaymentPlanSelected.assertValues([.pledgeOverTime])
    }
  }
}
