import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public typealias PledgeAmountData = (amount: Double, min: Double, max: Double, isValid: Bool)

public enum PledgeAmountStepperConstants {
  static let max: Double = 1_000_000_000
}

public protocol PledgeAmountViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func doneButtonTapped()
  func selectedShippingAmountChanged(to amount: Double)
  func stepperValueChanged(_ value: Double)
  func textFieldDidEndEditing(_ value: String?)
  func textFieldValueChanged(_ value: String?)
}

public protocol PledgeAmountViewModelOutputs {
  var currency: Signal<String, Never> { get }
  var doneButtonIsEnabled: Signal<Bool, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var labelTextColor: Signal<UIColor, Never> { get }
  var maxPledgeAmountErrorLabelIsHidden: Signal<Bool, Never> { get }
  var maxPledgeAmountErrorLabelText: Signal<String, Never> { get }
  var minPledgeAmountLabelIsHidden: Signal<Bool, Never> { get }
  var minPledgeAmountLabelText: Signal<String, Never> { get }
  var notifyDelegateAmountUpdated: Signal<PledgeAmountData, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperMinValue: Signal<Double, Never> { get }
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

    let shippingAmount = Signal.merge(
      self.projectAndRewardProperty.signal.mapConst(0),
      self.selectedShippingAmountChangedProperty.signal
    )

    let maxValue = minAndMax
      .map(second)
      .combineLatest(with: shippingAmount)
      .map(-)

    let textFieldInputValue = self.textFieldDidEndEditingProperty.signal
      .skipNil()
      .map(Double.init)
      .skipNil()
      .map(rounded)

    let initialValue = Signal.combineLatest(
      project,
      reward,
      minValue
    )
    .map(initialPledgeAmount)

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

    self.stepperMinValue = updatedValue
      .map { ($0.0, $0.2) }
      .map(min)

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

    self.notifyDelegateAmountUpdated = updatedValue
      .map { min, max, value in
        (rounded(value), min, max, min <= value && value <= max)
      }

    self.maxPledgeAmountErrorLabelIsHidden = updatedValue
      .map { _, max, value in value <= max }

    let isValueValid = self.notifyDelegateAmountUpdated
      .map { $0.3 }
      .skipRepeats()

    self.maxPledgeAmountErrorLabelText = updatedValue
      .map(second)
      .combineLatest(with: project)
      .map { max, project in
        Strings.The_maximum_pledge_is_max_pledge(
          max_pledge:
          Format.currency(max, country: project.country, omitCurrencyCode: false)
        )
      }
      .skipRepeats()

    self.doneButtonIsEnabled = isValueValid

    let textColor = isValueValid
      .map { $0 ? UIColor.ksr_green_500 : UIColor.ksr_red_400 }

    self.labelTextColor = textColor

    self.minPledgeAmountLabelIsHidden = reward
      .map { $0.isNoReward }

    self.minPledgeAmountLabelText = Signal.combineLatest(
      project,
      minValue
    )
    .map { project, min in
      Strings.The_minimum_pledge_is_min_pledge(
        min_pledge: Format.currency(min, country: project.country, omitCurrencyCode: false)
      )
    }

    self.stepperValue = self.notifyDelegateAmountUpdated.map { $0.0 }.skipRepeats()

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

  private let selectedShippingAmountChangedProperty = MutableProperty<Double>(0)
  public func selectedShippingAmountChanged(to amount: Double) {
    self.selectedShippingAmountChangedProperty.value = amount
  }

  public let currency: Signal<String, Never>
  public let doneButtonIsEnabled: Signal<Bool, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let labelTextColor: Signal<UIColor, Never>
  public let maxPledgeAmountErrorLabelIsHidden: Signal<Bool, Never>
  public let maxPledgeAmountErrorLabelText: Signal<String, Never>
  public let minPledgeAmountLabelIsHidden: Signal<Bool, Never>
  public let minPledgeAmountLabelText: Signal<String, Never>
  public let notifyDelegateAmountUpdated: Signal<PledgeAmountData, Never>
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperMinValue: Signal<Double, Never>
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

private func initialPledgeAmount(from project: Project, reward: Reward, minValue: Double) -> Double {
  guard userIsBacking(reward: reward, inProject: project),
    let backing = project.personalization.backing else { return minValue }

  return backing.pledgeAmount
}
