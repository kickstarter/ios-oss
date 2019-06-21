@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeAmountCellViewModelTests: TestCase {
  private let vm: PledgeAmountCellViewModelType = PledgeAmountCellViewModel()

  private let amount = TestObserver<String, Never>()
  private let currency = TestObserver<String, Never>()
  private let generateSelectionFeedback = TestObserver<Void, Never>()
  private let generateNotificationWarningFeedback = TestObserver<Void, Never>()
  private let stepperInitialValue = TestObserver<Double, Never>()
  private let stepperMinValue = TestObserver<Double, Never>()
  private let stepperMaxValue = TestObserver<Double, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amount.observe(self.amount.observer)
    self.vm.outputs.currency.observe(self.currency.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateNotificationWarningFeedback.observe(
      self.generateNotificationWarningFeedback.observer
    )
    self.vm.outputs.stepperInitialValue.observe(self.stepperInitialValue.observer)
    self.vm.outputs.stepperMinValue.observe(self.stepperMinValue.observer)
    self.vm.outputs.stepperMaxValue.observe(self.stepperMaxValue.observer)
  }

  func testAmountAndCurrency() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amount.assertValues(["15"])
    self.currency.assertValues(["$"])
  }

  func testGenerateSelectionFeedback() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.vm.inputs.stepperValueChanged(16)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(20)
    self.generateSelectionFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(14)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(10)
    self.generateSelectionFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(15)
    self.generateSelectionFeedback.assertValueCount(3)
  }

  func testGenerateNotificationWarningFeedback() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(16)
    self.generateNotificationWarningFeedback.assertValueCount(0)

    self.vm.inputs.stepperValueChanged(20)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(14)
    self.generateNotificationWarningFeedback.assertValueCount(1)

    self.vm.inputs.stepperValueChanged(10)
    self.generateNotificationWarningFeedback.assertValueCount(2)

    self.vm.inputs.stepperValueChanged(15)
    self.generateNotificationWarningFeedback.assertValueCount(2)
  }

  func testStepperInitialValue() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperInitialValue.assertValue(15)
  }

  func testStepperMinValue() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperMinValue.assertValue(10)
  }

  func testStepperMaxValue() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperMaxValue.assertValue(20)
  }
}
