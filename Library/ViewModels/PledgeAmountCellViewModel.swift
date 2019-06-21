import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeAmountCellViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func stepperValueChanged(_ value: Double)
}

public protocol PledgeAmountCellViewModelOutputs {
  var amount: Signal<String, Never> { get }
  var currency: Signal<String, Never> { get }
  var generateSelectionFeedback: Signal<Void, Never> { get }
  var generateNotificationWarningFeedback: Signal<Void, Never> { get }
  var stepperInitialValue: Signal<Double, Never> { get }
  var stepperMaxValue: Signal<Double, Never> { get }
  var stepperMinValue: Signal<Double, Never> { get }
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

    self.stepperInitialValue = initialValue

    self.amount = Signal.merge(
      initialValue,
      self.stepperValueProperty.signal
    )
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
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  private let stepperValueProperty = MutableProperty<Double>(0)
  public func stepperValueChanged(_ value: Double) {
    self.stepperValueProperty.value = value
  }

  public let amount: Signal<String, Never>
  public let currency: Signal<String, Never>
  public let generateSelectionFeedback: Signal<Void, Never>
  public let generateNotificationWarningFeedback: Signal<Void, Never>
  public let stepperInitialValue: Signal<Double, Never>
  public let stepperMaxValue: Signal<Double, Never>
  public let stepperMinValue: Signal<Double, Never>

  public var inputs: PledgeAmountCellViewModelInputs { return self }
  public var outputs: PledgeAmountCellViewModelOutputs { return self }
}
