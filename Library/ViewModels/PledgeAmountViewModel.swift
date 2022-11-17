import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

public typealias PledgeAmountData = (amount: Double, min: Double, max: Double, isValid: Bool)

public typealias PledgeAmountViewConfigData = (
  project: Project,
  reward: Reward,
  currentAmount: Double
)

public enum PledgeAmountStepperConstants {
  static let max: Double = 1_000_000_000
}

public protocol PledgeAmountViewModelInputs {
  func configureWith(data: PledgeAmountViewConfigData)
  func doneButtonTapped()
  func stepperValueChanged(_ value: Double)
  func textFieldDidEndEditing(_ value: String?)
  func textFieldValueChanged(_ value: String?)
  func unavailableAmountChanged(to amount: Double)
}

public protocol PledgeAmountViewModelOutputs {
  var currency: Signal<String, Never> { get }
  var doneButtonIsEnabled: Signal<Bool, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var labelTextColor: Signal<UIColor, Never> { get }
  var maxPledgeAmountErrorLabelIsHidden: Signal<Bool, Never> { get }
  var maxPledgeAmountErrorLabelText: Signal<String, Never> { get }
  var plusSignLabelHidden: Signal<Bool, Never> { get }
  var notifyDelegateAmountUpdated: Signal<PledgeAmountData, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperMinValue: Signal<Double, Never> { get }
  var stepperValue: Signal<Double, Never> { get }
  var subTitleLabelHidden: Signal<Bool, Never> { get }
  var textFieldIsFirstResponder: Signal<Bool, Never> { get }
  var textFieldTextColor: Signal<UIColor?, Never> { get }
  var textFieldValue: Signal<String, Never> { get }
  var titleLabelText: Signal<String, Never> { get }
}

public protocol PledgeAmountViewModelType {
  var inputs: PledgeAmountViewModelInputs { get }
  var outputs: PledgeAmountViewModelOutputs { get }
}

public final class PledgeAmountViewModel: PledgeAmountViewModelType,
  PledgeAmountViewModelInputs, PledgeAmountViewModelOutputs {
  public init() {
    let configData = self.projectAndRewardProperty.signal
      .skipNil()

    let project = configData
      .map(first)

    let reward = configData
      .map(second)

    let currentAmount = configData
      .map(third)

    let minAndMax = Signal.combineLatest(
      project,
      reward
    )
    .map { project, reward -> (Double, Double) in
      let (min, max) = minAndMaxPledgeAmount(forProject: project, reward: reward)

      // Minimum amount for regular rewards is zero as this is the "bonus support" amount.
      return (reward.isNoReward ? min : 0, max)
    }

    let minValue = minAndMax
      .map(first)

    let unavailableAmount = Signal.merge(
      self.projectAndRewardProperty.signal.mapConst(0)
        .take(until: self.unavailableAmountChangedProperty.signal.ignoreValues()),
      self.unavailableAmountChangedProperty.signal
    )

    let maxValue = minAndMax
      .map(second)
      .combineLatest(with: unavailableAmount)
      .map(-)

    let textFieldInputValue = self.textFieldDidEndEditingProperty.signal
      .skipNil()
      .map(Double.init)
      .skipNil()
      .map { rounded($0, places: 2) }

    let initialValue = Signal.combineLatest(
      project,
      currentAmount,
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
      .map {
        let projectCurrencyCountry = projectCountry(forCurrency: $0.stats.currency) ?? $0.country

        return currencySymbol(forCountry: projectCurrencyCountry).trimmed()
      }

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
      .filter { min, max, value in
        value <= min || max <= value
      }
      .ignoreValues()

    self.notifyDelegateAmountUpdated = updatedValue
      .map { min, max, value in
        (rounded(value, places: 2), min, max, min <= value && value <= max)
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
        let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country
        let maxPledge = Format.currency(max, country: projectCurrencyCountry, omitCurrencyCode: false)

        return Strings.Enter_an_amount_less_than_max_pledge(max_pledge: maxPledge)
      }
      .skipRepeats()

    self.doneButtonIsEnabled = isValueValid

    let textColor = isValueValid
      .map { $0 ? UIColor.ksr_create_700 : UIColor.ksr_alert }

    self.labelTextColor = textColor

    self.stepperValue = self.notifyDelegateAmountUpdated.map { $0.0 }.skipRepeats()

    self.textFieldIsFirstResponder = self.doneButtonTappedProperty.signal
      .mapConst(false)

    self.textFieldTextColor = textColor
      .wrapInOptional()

    self.plusSignLabelHidden = reward.map(\.isNoReward)
    self.subTitleLabelHidden = reward.map(\.isNoReward)
    self.titleLabelText = reward.map(\.isNoReward).map {
      $0 ? Strings.Your_pledge_amount() : Strings.Bonus_support()
    }
  }

  private let projectAndRewardProperty = MutableProperty<PledgeAmountViewConfigData?>(nil)
  public func configureWith(data: PledgeAmountViewConfigData) {
    self.projectAndRewardProperty.value = data
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

  private let unavailableAmountChangedProperty = MutableProperty<Double>(0)
  public func unavailableAmountChanged(to amount: Double) {
    self.unavailableAmountChangedProperty.value = amount
  }

  public let currency: Signal<String, Never>
  public let doneButtonIsEnabled: Signal<Bool, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let labelTextColor: Signal<UIColor, Never>
  public let maxPledgeAmountErrorLabelIsHidden: Signal<Bool, Never>
  public let maxPledgeAmountErrorLabelText: Signal<String, Never>
  public let notifyDelegateAmountUpdated: Signal<PledgeAmountData, Never>
  public let plusSignLabelHidden: Signal<Bool, Never>
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperMinValue: Signal<Double, Never>
  public let stepperValue: Signal<Double, Never>
  public let subTitleLabelHidden: Signal<Bool, Never>
  public let textFieldTextColor: Signal<UIColor?, Never>
  public let textFieldIsFirstResponder: Signal<Bool, Never>
  public let textFieldValue: Signal<String, Never>
  public let titleLabelText: Signal<String, Never>

  public var inputs: PledgeAmountViewModelInputs { return self }
  public var outputs: PledgeAmountViewModelOutputs { return self }
}

// MARK: - Functions

private func initialPledgeAmount(
  from project: Project,
  currentAmount: Double,
  minValue: Double
) -> Double {
  guard userIsBackingProject(project) else { return minValue }

  return max(currentAmount, minValue)
}

/*
 A helper that assists in rounding a Double to a given number of decimal places
 NB: Do not use this for rounding elsewhere.
 */
private func rounded(_ value: Double, places: Int) -> Double {
  let divisor = pow(10.0, Double(places))
  return (value * divisor).rounded() / divisor
}
