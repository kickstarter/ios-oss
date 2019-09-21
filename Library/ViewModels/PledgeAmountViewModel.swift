import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeAmountViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func doneButtonTapped()
  func stepperValueChanged(_ value: Double)
  func textFieldDidEndEditing(_ value: String?)
  func textFieldValueChanged(_ value: String?)
}

public protocol PledgeAmountViewModelOutputs {
  var amountPrimitive: Signal<Double, Never> { get }
  var currency: Signal<String, Never> { get }
  var doneButtonIsEnabled: Signal<Bool, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var labelTextColor: Signal<UIColor, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperMinValue: Signal<Double, Never> { get }
  var stepperStepValue: Signal<Double, Never> { get }
  var stepperValue: Signal<Double, Never> { get }
  var textFieldIsFirstResponder: Signal<Bool, Never> { get }
  var textFieldTextColor: Signal<UIColor?, Never> { get }
  var textFieldValue: Signal<String, Never> { get }
}

public protocol PledgeAmountViewModelType {
  var inputs: PledgeAmountViewModelInputs { get }
  var outputs: PledgeAmountViewModelOutputs { get }
}

public final class PledgeAmountViewModel: PledgeAmountViewModelType,
  PledgeAmountViewModelInputs, PledgeAmountViewModelOutputs {
  public init() {
    let project = self.projectAndRewardProperty.signal
      .skipNil()
      .map(first)

    let reward = self.projectAndRewardProperty.signal
      .skipNil()
      .map(second)

    let minAndMax = Signal.combineLatest(
      project,
      reward
    )
    .map(minAndMaxPledgeAmount)

    let minValue = minAndMax
      .map(first)

    let maxValue = minAndMax
      .map(second)

    let textFieldInputValue = self.textFieldDidEndEditingProperty.signal
      .skipNil()
      .map(Double.init)
      .skipNil()

    let stepperValue = Signal.merge(
      minValue,
      textFieldInputValue,
      self.stepperValueProperty.signal
    )

    self.textFieldValue = stepperValue
      .map { String(format: "%.0f", $0) }
      .skipRepeats()

    self.currency = project
      .map { currencySymbol(forCountry: $0.country).trimmed() }

    self.stepperMinValue = minValue.mapConst(0)
    self.stepperMaxValue = minValue.mapConst(Double.greatestFiniteMagnitude)

    let stepperValueChanged = Signal.combineLatest(
      self.stepperMinValue.signal,
      self.stepperMaxValue.signal,
      self.stepperValueProperty.signal
    )

    self.generateSelectionFeedback = stepperValueChanged
      .filter { min, max, value in min < value && value < max }
      .ignoreValues()

    self.generateNotificationWarningFeedback = stepperValueChanged
      .filter { min, max, value in value <= min || max <= value }
      .ignoreValues()

    let textFieldValue = self.textFieldValueProperty.signal
      .map { $0.coalesceWith("") }
      .map(Double.init)
      .map { $0.coalesceWith(0) }

    let updatedValue = Signal.combineLatest(
      minValue,
      maxValue,
      Signal.merge(
        stepperValue,
        textFieldValue.signal
      )
    )

    self.amountPrimitive = updatedValue
      .map(third)
      .skipRepeats()

    let isValueValid = updatedValue
      .map { (min: Double, max: Double, doubleValue: Double) -> Bool in
        min <= doubleValue && doubleValue <= max
      }

    self.doneButtonIsEnabled = isValueValid

    let textColor = isValueValid
      .map { $0 ? UIColor.ksr_green_500 : UIColor.ksr_red_400 }

    self.labelTextColor = textColor

    self.stepperStepValue = minValue

    self.stepperValue = Signal.merge(
      minValue,
      textFieldValue
    )

    self.textFieldIsFirstResponder = self.doneButtonTappedProperty.signal
      .mapConst(false)

    self.textFieldTextColor = textColor
      .wrapInOptional()
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  private let doneButtonTappedProperty = MutableProperty(())
  public func doneButtonTapped() {
    self.doneButtonTappedProperty.value = ()
  }

  private let stepperValueProperty = MutableProperty<Double>(0)
  public func stepperValueChanged(_ value: Double) {
    self.stepperValueProperty.value = value
  }

  private let textFieldDidEndEditingProperty = MutableProperty<String?>(nil)
  public func textFieldDidEndEditing(_ value: String?) {
    self.textFieldDidEndEditingProperty.value = value
  }

  private let textFieldValueProperty = MutableProperty<String?>(nil)
  public func textFieldValueChanged(_ value: String?) {
    self.textFieldValueProperty.value = value
  }

  public let amountPrimitive: Signal<Double, Never>
  public let currency: Signal<String, Never>
  public let doneButtonIsEnabled: Signal<Bool, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let labelTextColor: Signal<UIColor, Never>
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperMinValue: Signal<Double, Never>
  public let stepperStepValue: Signal<Double, Never>
  public let stepperValue: Signal<Double, Never>
  public let textFieldTextColor: Signal<UIColor?, Never>
  public let textFieldIsFirstResponder: Signal<Bool, Never>
  public let textFieldValue: Signal<String, Never>

  public var inputs: PledgeAmountViewModelInputs { return self }
  public var outputs: PledgeAmountViewModelOutputs { return self }
}
