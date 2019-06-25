@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeAmountCellViewModelTests: TestCase {
  private let vm: PledgeAmountCellViewModelType = PledgeAmountCellViewModel()

  private let amount = TestObserver<String, Never>()
  private let amountPrimitive = TestObserver<Double, Never>()
  private let currency = TestObserver<String, Never>()
  private let doneButtonIsEnabled = TestObserver<Bool, Never>()
  private let generateSelectionFeedback = TestObserver<Void, Never>()
  private let generateNotificationWarningFeedback = TestObserver<Void, Never>()
  private let stepperMinValue = TestObserver<Double, Never>()
  private let stepperMaxValue = TestObserver<Double, Never>()
  private let stepperValue = TestObserver<Double, Never>()
  private let textFieldIsFirstResponder = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.amount.observe(self.amount.observer)
    self.vm.outputs.amountPrimitive.observe(self.amountPrimitive.observer)
    self.vm.outputs.currency.observe(self.currency.observer)
    self.vm.outputs.doneButtonIsEnabled.observe(self.doneButtonIsEnabled.observer)
    self.vm.outputs.generateSelectionFeedback.observe(self.generateSelectionFeedback.observer)
    self.vm.outputs.generateNotificationWarningFeedback.observe(
      self.generateNotificationWarningFeedback.observer
    )
    self.vm.outputs.stepperValue.observe(self.stepperValue.observer)
    self.vm.outputs.stepperMinValue.observe(self.stepperMinValue.observer)
    self.vm.outputs.stepperMaxValue.observe(self.stepperMaxValue.observer)
    self.vm.outputs.textFieldIsFirstResponder.observe(self.textFieldIsFirstResponder.observer)
  }

  func testAmountAndCurrency() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amount.assertValues(["15"])
    self.amountPrimitive.assertValues([15])
    self.currency.assertValues(["$"])

    let project = Project.template
      |> Project.lens.country .~ .jp

    let reward = Reward.template
      |> Reward.lens.minimum .~ 200

    self.vm.inputs.configureWith(project: project, reward: reward)

    self.amount.assertValues(["15", "15", "15"])
    self.amountPrimitive.assertValues([15])
    self.currency.assertValues(["$", "¥"])
  }

  func testDoneButtonIsEnabled_Stepper() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.stepperValueChanged(16)
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.stepperValueChanged(20)
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(1)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.stepperValueChanged(10)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_TextField() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("16")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.textFieldValueChanged("200")
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("20")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.textFieldValueChanged("1")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("10")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
  }

  func testDoneButtonIsEnabled_Combined() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.doneButtonIsEnabled.assertValues([true])

    self.vm.inputs.textFieldValueChanged("16")
    self.doneButtonIsEnabled.assertValues([true, true])

    self.vm.inputs.stepperValueChanged(200)
    self.doneButtonIsEnabled.assertValues([true, true, false])

    self.vm.inputs.textFieldValueChanged("20")
    self.doneButtonIsEnabled.assertValues([true, true, false, true])

    self.vm.inputs.stepperValueChanged(1)
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false])

    self.vm.inputs.textFieldValueChanged("10")
    self.doneButtonIsEnabled.assertValues([true, true, false, true, false, true])
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

  func testStepperMinValue() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperMinValue.assertValue(10)
  }

  func testStepperMaxValue() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperMaxValue.assertValue(20)
  }

  func testStepperValue() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperValue.assertValue(15)
  }

  func testStepperValueChangesWithTextFieldInput() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.stepperValue.assertValue(15)

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([15, 11])

    self.vm.inputs.textFieldValueChanged("16")
    self.stepperValue.assertValues([15, 11, 16])

    self.vm.inputs.textFieldValueChanged("100")
    self.stepperValue.assertValues([15, 11, 16, 20])

    self.vm.inputs.textFieldValueChanged("1")
    self.stepperValue.assertValues([15, 11, 16, 20, 10])

    self.vm.inputs.textFieldValueChanged("11")
    self.stepperValue.assertValues([15, 11, 16, 20, 10, 11])
  }

  func testTextFieldIsFirstResponder() {
    self.vm.inputs.doneButtonTapped()

    self.textFieldIsFirstResponder.assertValue(false)
  }

  func testNilInputReturnsZero() {
    self.vm.inputs.configureWith(project: .template, reward: .template)

    self.amountPrimitive.assertValue(15)

    self.vm.inputs.textFieldValueChanged("11")
    self.amountPrimitive.assertValues([15, 11])

    self.vm.inputs.textFieldValueChanged("")
    self.amountPrimitive.assertValues([15, 11, 0])

    self.vm.inputs.textFieldValueChanged("5")
    self.amountPrimitive.assertValues([15, 11, 0, 5])

    self.vm.inputs.textFieldValueChanged(nil)
    self.amountPrimitive.assertValues([15, 11, 0, 5, 0])
  }
}
