import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public enum PledgeAmountStepperConstants {
  static let min: Double = 0
  static let max: Double = 1_000_000_000
}

public protocol PledgeAmountViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func doneButtonTapped()
  func stepperValueChanged(_ value: Double)
  func textFieldDidEndEditing(_ value: String?)
  func textFieldValueChanged(_ value: String?)
}

public protocol PledgeAmountViewModelOutputs {
  var amount: Signal<(Double, Bool), Never> { get }
  var currency: Signal<String, Never> { get }
  var doneButtonIsEnabled: Signal<Bool, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var labelTextColor: Signal<UIColor, Never> { get }
  var minPledgeAmountLabelText: Signal<String, Never> { get }
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
      .map(rounded)

    let initialValue = Signal.combineLatest(
      project
        .map { $0.personalization.backing?.pledgeAmount },
      minValue
    )
    .map { backedAmount, minValue in backedAmount ?? minValue }

    let stepperValue = Signal.merge(
      initialValue,
      textFieldInputValue,
      self.stepperValueProperty.signal
    )

    self.textFieldValue = stepperValue
      .map { value in
        // Adds trailing zeros if the rounded number has non-zero remainder
        // Removes trailing zeros and the decimal point otherwise
        // Example:
        //  25 => 25
        //  25. => 25
        //  25.0  => 25
        //  25.00 => 25
        //  25.1 => 25.10
        //  25.10 = 25.10
        let numberOfDecimalPlaces = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return String(format: "%.\(numberOfDecimalPlaces)f", value)
      }

    self.currency = project
      .map { currencySymbol(forCountry: $0.country).trimmed() }

    self.stepperMinValue = minValue.mapConst(PledgeAmountStepperConstants.min)
    self.stepperMaxValue = minValue.mapConst(PledgeAmountStepperConstants.max)

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

    self.amount = updatedValue
      .map { min, max, value in
        (rounded(value), min <= value && value <= max)
      }

    let isValueValid = self.amount
      .map(second)
      .skipRepeats()

    self.doneButtonIsEnabled = isValueValid

    let textColor = isValueValid
      .map { $0 ? UIColor.ksr_green_500 : UIColor.ksr_red_400 }

    self.labelTextColor = textColor

    self.minPledgeAmountLabelText = Signal.combineLatest(
      project,
      minValue
    )
    .map { project, min in
      localizedString(
        key: "The_minimum_pledge_is",
        defaultValue: "The minimum pledge is %{min_pledge}.",
        count: nil,
        substitutions: ["min_pledge": Format.currency(min, country: project.country, omitCurrencyCode: false)]
      )
    }

    self.stepperStepValue = minValue

    self.stepperValue = Signal.merge(
      minValue,
      self.amount.map(first)
    )
    .skipRepeats()

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

  public let amount: Signal<(Double, Bool), Never>
  public let currency: Signal<String, Never>
  public let doneButtonIsEnabled: Signal<Bool, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let labelTextColor: Signal<UIColor, Never>
  public let minPledgeAmountLabelText: Signal<String, Never>
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

// MARK: - Functions

// Limits the amount of decimal numbers to 2
// Example:
//  rounded(1.12) => 1.12
//  rounded(1.123) => 1.12
//  rounded(1.125) => 1.13
//  rounded(1.123456789) => 1.12
private func rounded(_ value: Double) -> Double {
  return round(value * 100) / 100
}
