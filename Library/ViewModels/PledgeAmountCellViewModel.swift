import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeAmountCellViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func doneButtonTapped()
  func stepperValueChanged(_ value: Double)
  func textFieldDidEndEditing(_ value: String?)
  func textFieldValueChanged(_ value: String?)
}

public protocol PledgeAmountCellViewModelOutputs {
  var amountPrimitive: Signal<Double, Never> { get }
  var currency: Signal<String, Never> { get }
  var doneButtonIsEnabled: Signal<Bool, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperMinValue: Signal<Double, Never> { get }
  var stepperStepValue: Signal<Double, Never> { get }
  var stepperValue: Signal<Double, Never> { get }
  var textFieldIsFirstResponder: Signal<Bool, Never> { get }
  var textFieldValue: Signal<String, Never> { get }
}

public protocol PledgeAmountCellViewModelType {
  var inputs: PledgeAmountCellViewModelInputs { get }
  var outputs: PledgeAmountCellViewModelOutputs { get }
}

public final class PledgeAmountCellViewModel: PledgeAmountCellViewModelType,
  PledgeAmountCellViewModelInputs, PledgeAmountCellViewModelOutputs {
  public init() {
    let project = self.projectAndRewardProperty.signal
      .skipNil()
      .map(first)

    let reward = self.projectAndRewardProperty.signal
      .skipNil()
      .map(second)

    let minAndMax = Signal.combineLatest(project, reward)
      .map(minAndMaxPledgeAmount)

    let initialValue = minAndMax
      .map(first)

    let clampedTextFieldValue = Signal.combineLatest(
      minAndMax.signal,
      self.textFieldDidEndEditingProperty.signal
        .skipNil()
    )
    .map(unpack)
    .map(clampedValue)

    let stepperValue = Signal.merge(
      initialValue,
      clampedTextFieldValue,
      self.stepperValueProperty.signal
    )

    self.textFieldValue = stepperValue
      .map { String(format: "%.0f", $0) }
      .skipRepeats()

    self.currency = project
      .map { currencySymbol(forCountry: $0.country).trimmed() }

    self.stepperMinValue = minAndMax.signal
      .map(first)

    self.stepperMaxValue = minAndMax.signal
      .map(second)

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
      self.stepperMinValue,
      self.stepperMaxValue,
      Signal.merge(
        stepperValue,
        textFieldValue.signal
      )
    )

    self.amountPrimitive = updatedValue
      .map(third)
      .skipRepeats()

    self.doneButtonIsEnabled = updatedValue
      .map { min, max, doubleValue in min <= doubleValue && doubleValue <= max }

    self.stepperStepValue = self.stepperMinValue

    let clampedStepperValue = Signal.combineLatest(
      self.stepperMinValue,
      self.stepperMaxValue,
      self.textFieldValueProperty.signal.skipNil()
    )
    .map(clampedValue)

    self.stepperValue = Signal.merge(
      initialValue,
      clampedStepperValue
    )

    self.textFieldIsFirstResponder = self.doneButtonTappedProperty.signal
      .mapConst(false)
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
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperMinValue: Signal<Double, Never>
  public let stepperStepValue: Signal<Double, Never>
  public let stepperValue: Signal<Double, Never>
  public let textFieldIsFirstResponder: Signal<Bool, Never>
  public let textFieldValue: Signal<String, Never>

  public var inputs: PledgeAmountCellViewModelInputs { return self }
  public var outputs: PledgeAmountCellViewModelOutputs { return self }
}

// MARK: - Functions

private func clampedValue(_ min: Double, max: Double, value: String) -> Double {
  switch (min, max, value) {
  case let (min, _, v) where v.isEmpty: return min
  case let (min, _, v as NSString) where v.doubleValue < min: return min
  case let (_, max, v as NSString) where v.doubleValue > max: return max
  case let (_, _, v as NSString): return v.doubleValue
  }
}
