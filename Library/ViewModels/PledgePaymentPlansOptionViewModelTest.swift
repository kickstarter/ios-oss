import Foundation
@testable import KsApi
@testable import Library
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgePaymentPlansOptionViewModelTest: TestCase {
  // MARK: Properties

  private var vm: PledgePaymentPlansOptionViewModelType = PledgePaymentPlansOptionViewModel()

  private var selectionIndicatorImageName = TestObserver<String, Never>()
  private var titleText = TestObserver<String, Never>()
  private var subtitleText = TestObserver<String, Never>()
  private var subtitleLabelHidden = TestObserver<Bool, Never>()
  private var notifyDelegatePaymentPlanOptionSelected = TestObserver<PledgePaymentPlansType, Never>()
  private var paymentIncrementsHidden = TestObserver<Bool, Never>()
  private var termsOfUseButtonHidden = TestObserver<Bool, Never>()
  private var paymentIncrements = TestObserver<[PledgePaymentIncrementFormatted], Never>()
  private var ineligibleBadgeHidden = TestObserver<Bool, Never>()
  private var ineligibleBadgeText = TestObserver<String, Never>()

  // MARK: Const

  // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
  private let pledgeInFullTitle = "Pledge in full"
  private let pledgeOverTimeTitle = "Pledge Over Time"
  private let pledgeOverTimeSubtitle =
    "You will be charged for your pledge over four payments, at no extra cost."
  private let pledgeOverTimeFullSubtitle =
    "You will be charged for your pledge over four payments, at no extra cost.\n\nThe first charge will be 24 hours after the project ends successfully, then every 2 weeks until fully paid. When this option is selected no further edits can be made to your pledge."
  private let selectedImageName = "icon-payment-method-selected"
  private let unselectedImageName = "icon-payment-method-unselected"
  private let thresholdAmount = 125.0

  // MARK: Lifecycle

  override func setUp() {
    super.setUp()

    self.vm.outputs.selectionIndicatorImageName.observe(self.selectionIndicatorImageName.observer)
    self.vm.outputs.titleText.observe(self.titleText.observer)
    self.vm.outputs.subtitleText.observe(self.subtitleText.observer)
    self.vm.outputs.subtitleLabelHidden.observe(self.subtitleLabelHidden.observer)
    self.vm.outputs.notifyDelegatePaymentPlanOptionSelected
      .observe(self.notifyDelegatePaymentPlanOptionSelected.observer)
    self.vm.outputs.paymentIncrementsHidden.observe(self.paymentIncrementsHidden.observer)
    self.vm.outputs.termsOfUseButtonHidden.observe(self.termsOfUseButtonHidden.observer)
    self.vm.outputs.paymentIncrements.observe(self.paymentIncrements.observer)
    self.vm.outputs.ineligibleBadgeHidden.observe(self.ineligibleBadgeHidden.observer)
    self.vm.outputs.ineligibleBadgeText.observe(self.ineligibleBadgeText.observer)
  }

  // MARK: Test cases

  func testPaymentPlanOption_PledgeinFull_Selected() {
    let data = PledgePaymentPlanOptionData(
      ineligible: false,
      type: .pledgeInFull,
      selectedType: .pledgeInFull,
      paymentIncrements: mockPaymentIncrements(),
      project: Project.template,
      thresholdAmount: self.thresholdAmount
    )
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeInFullTitle)
    self.subtitleText.assertValue("")
    self.subtitleLabelHidden.assertValue(true)
    self.paymentIncrementsHidden.assertValue(true)
    self.selectionIndicatorImageName.assertValue(self.selectedImageName)
    self.paymentIncrements.assertValues([])
    self.ineligibleBadgeHidden.assertValue(true)
    self.ineligibleBadgeText.assertDidNotEmitValue()
  }

  func testPaymentPlanOption_PledgeinFull_Unselected() {
    let data = PledgePaymentPlanOptionData(
      ineligible: false,
      type: .pledgeInFull,
      selectedType: .pledgeOverTime,
      paymentIncrements: mockPaymentIncrements(),
      project: Project.template,
      thresholdAmount: self.thresholdAmount
    )
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeInFullTitle)
    self.subtitleText.assertValue("")
    self.subtitleLabelHidden.assertValue(true)
    self.termsOfUseButtonHidden.assertValue(true)
    self.paymentIncrementsHidden.assertValue(true)
    self.selectionIndicatorImageName.assertValue(self.unselectedImageName)
    self.paymentIncrements.assertValues([])
    self.ineligibleBadgeHidden.assertValue(true)
    self.ineligibleBadgeText.assertDidNotEmitValue()
  }

  func testPaymentPlanOption_PledgeOverTime_Selected() {
    let increments = mockPaymentIncrements()
    let project = Project.template
    let incrementsFormatted = paymentIncrementsFormatted(from: increments, project: project)
    let data = PledgePaymentPlanOptionData(
      ineligible: false,
      type: .pledgeOverTime,
      selectedType: .pledgeOverTime,
      paymentIncrements: increments,
      project: project,
      thresholdAmount: self.thresholdAmount
    )

    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeOverTimeTitle)
    self.subtitleText.assertValue(self.pledgeOverTimeFullSubtitle)
    self.subtitleLabelHidden.assertValue(false)
    self.termsOfUseButtonHidden.assertValue(false)
    self.paymentIncrementsHidden.assertValue(false)

    self.selectionIndicatorImageName.assertValue(self.selectedImageName)
    self.paymentIncrements.assertValues([incrementsFormatted])
    self.ineligibleBadgeHidden.assertValue(true)
    self.ineligibleBadgeText.assertDidNotEmitValue()
  }

  func testPaymentPlanOption_PledgeOverTime_Unselected() {
    let data = PledgePaymentPlanOptionData(
      ineligible: false,
      type: .pledgeOverTime,
      selectedType: .pledgeInFull,
      paymentIncrements: mockPaymentIncrements(),
      project: Project.template,
      thresholdAmount: self.thresholdAmount
    )
    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeOverTimeTitle)
    self.subtitleText.assertValue(self.pledgeOverTimeSubtitle)
    self.subtitleLabelHidden.assertValue(false)
    self.termsOfUseButtonHidden.assertValue(true)
    self.paymentIncrementsHidden.assertValue(true)
    self.selectionIndicatorImageName.assertValue(self.unselectedImageName)
    self.paymentIncrements.assertValues([])
    self.ineligibleBadgeHidden.assertValue(true)
    self.ineligibleBadgeText.assertDidNotEmitValue()
  }

  func testPaymentPlanOption_OptionTapped() {
    let data = PledgePaymentPlanOptionData(
      ineligible: false,
      type: .pledgeOverTime,
      selectedType: .pledgeInFull,
      paymentIncrements: mockPaymentIncrements(),
      project: Project.template,
      thresholdAmount: self.thresholdAmount
    )
    self.vm.inputs.configureWith(data: data)
    self.vm.inputs.optionTapped()
    self.notifyDelegatePaymentPlanOptionSelected.assertValue(.pledgeOverTime)
  }

  func testPaymentPlanOption_PledgeOverTime_Ineligible() {
    let project = Project.template
    // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
    let ineligibleText = "Available for pledges over $125"

    let data = PledgePaymentPlanOptionData(
      ineligible: true,
      type: .pledgeOverTime,
      selectedType: .pledgeInFull,
      paymentIncrements: [],
      project: project,
      thresholdAmount: self.thresholdAmount
    )

    self.vm.inputs.configureWith(data: data)

    self.titleText.assertValue(self.pledgeOverTimeTitle)
    self.ineligibleBadgeHidden.assertValue(false)
    self.ineligibleBadgeText.assertValue(ineligibleText)
  }
}

private func mockPaymentIncrements() -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(amount: 250.0, currency: "USD")
  let scheduledCollection = TimeInterval(1_553_731_200)
  return [
    PledgePaymentIncrement(amount: amount, scheduledCollection: scheduledCollection),
    PledgePaymentIncrement(amount: amount, scheduledCollection: scheduledCollection)
  ]
}

private func paymentIncrementsFormatted(from increments: [PledgePaymentIncrement], project: Project)
  -> [PledgePaymentIncrementFormatted] {
  increments.enumerated().map {
    PledgePaymentIncrementFormatted(from: $1, index: $0, project: project)
  }
}
