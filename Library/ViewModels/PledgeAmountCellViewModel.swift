import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeAmountCellViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func doneButtonTapped()
  func stepperValueChanged(_ value: Double)
  func textFieldValueChanged(_ value: String?)
}

public protocol PledgeAmountCellViewModelOutputs {
  var amount: Signal<String, Never> { get }
  var currency: Signal<String, Never> { get }
  var doneButtonIsEnabled: Signal<Bool, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperMinValue: Signal<Double, Never> { get }
  var stepperValue: Signal<Double, Never> { get }
  var textFieldIsFirstResponder: Signal<Bool, Never> { get }
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

    let initialValue = Signal.combineLatest(project, reward)
      .map { _ in 15.0 }

    let stepperValue = Signal.merge(
      initialValue,
      self.stepperValueProperty.signal
    )

    self.amount = stepperValue
      .map { String(format: "%.0f", $0) }

    self.currency = project
      .map { currencySymbol(forCountry: $0.country).trimmed() }

    let minAndMax = Signal.combineLatest(project, reward)
      .map { _ in (10.0, 20.0) }

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
      .skipNil()
      .map(Double.init)
      .skipNil()

    self.doneButtonIsEnabled = Signal.combineLatest(
      self.stepperMinValue,
      self.stepperMaxValue,
      Signal.merge(
        stepperValue,
        textFieldValue.signal
      )
    )
    .map { min, max, doubleValue in min <= doubleValue && doubleValue <= max }

    let clampedStepperValue = Signal.combineLatest(
      self.stepperMinValue,
      self.stepperMaxValue,
      textFieldValue.signal
    )
    .map { minValue, maxValue, value in min(max(minValue, value), maxValue) }

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

  private let textFieldValueProperty = MutableProperty<String?>(nil)
  public func textFieldValueChanged(_ value: String?) {
    self.textFieldValueProperty.value = value
  }

  public let amount: Signal<String, Never>
  public let currency: Signal<String, Never>
  public let doneButtonIsEnabled: Signal<Bool, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperMinValue: Signal<Double, Never>
  public let stepperValue: Signal<Double, Never>
  public let textFieldIsFirstResponder: Signal<Bool, Never>

  public var inputs: PledgeAmountCellViewModelInputs { return self }
  public var outputs: PledgeAmountCellViewModelOutputs { return self }
}
