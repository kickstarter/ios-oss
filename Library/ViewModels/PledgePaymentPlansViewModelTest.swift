import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentPlansViewModelTests: TestCase {
  // MARK: Properties

  private var vm: PledgePaymentPlansViewModelType = PledgePaymentPlansViewModel()

  private var reloadPaymentPlansPlanType = TestObserver<PledgePaymentPlansType, Never>()
  private var notifyDelegatePaymentPlanSelected = TestObserver<PledgePaymentPlansType, Never>()
  private var notifyDelegateTermsOfUseTapped = TestObserver<HelpType, Never>()

  private let selectionData = PledgePaymentPlansAndSelectionData(
    selectedPlan: .pledgeInFull,
    project: Project.template,
    thresholdAmount: 125.0
  )

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegatePaymentPlanSelected
      .observe(self.notifyDelegatePaymentPlanSelected.observer)

    self.vm.outputs.reloadPaymentPlans
      .map { $0.selectedPlan }
      .observe(self.reloadPaymentPlansPlanType.observer)

    self.vm.outputs.notifyDelegateTermsOfUseTapped.observe(self.notifyDelegateTermsOfUseTapped.observer)
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

      self.vm.inputs.configure(with: self.selectionData)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull])
      self.notifyDelegatePaymentPlanSelected.assertDidNotEmitValue()
    }
  }

  func testPaymenPlans_PledgeInFullSelected() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.configure(with: self.selectionData)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull])
      self.vm.inputs.didSelectPlanType(.pledgeInFull)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull, .pledgeInFull])
      self.notifyDelegatePaymentPlanSelected.assertValues([.pledgeInFull])
    }
  }

  func testPaymenPlans_PledgeOverTimeSelected() {
    withEnvironment {
      self.vm.inputs.viewDidLoad()

      self.vm.inputs.configure(with: self.selectionData)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull])
      self.vm.inputs.didSelectPlanType(.pledgeOverTime)
      self.reloadPaymentPlansPlanType.assertValues([.pledgeInFull, .pledgeOverTime])
      self.notifyDelegatePaymentPlanSelected.assertValues([.pledgeOverTime])
    }
  }

  func testPaymenPlans_TermsOfUseTapped() {
    self.vm.inputs.viewDidLoad()

    self.vm.inputs.configure(with: self.selectionData)
    self.vm.inputs.didTapTermsOfUse(with: .terms)

    self.notifyDelegateTermsOfUseTapped.assertValues([HelpType.terms])
  }
}
