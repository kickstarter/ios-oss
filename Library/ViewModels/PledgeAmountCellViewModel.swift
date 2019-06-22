import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeAmountCellViewModelInputs {
  func amountUpdated(to amount: String)
  func configureWith(project: Project, reward: Reward)
}

public protocol PledgeAmountCellViewModelOutputs {
  var amount: Signal<String, Never> { get }
  var amountPrimitive: Signal<Double, Never> { get }
  var currency: Signal<String, Never> { get }
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

    self.amount = reward
      .map { String(format: "%.0f", $0.minimum) }

    let updatedAmount = self.amountSignal
      .map(Double.init)
      .skipNil()

    self.amountPrimitive = Signal.merge(
      reward.map { $0.minimum },
      updatedAmount
    )

    self.currency = project
      .map { currencySymbol(forCountry: $0.country).trimmed() }
  }

  private let (amountSignal, amountObserver) = Signal<String, Never>.pipe()
  public func amountUpdated(to amount: String) {
    self.amountObserver.send(value: amount)
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  public let amount: Signal<String, Never>
  public let amountPrimitive: Signal<Double, Never>
  public let currency: Signal<String, Never>

  public var inputs: PledgeAmountCellViewModelInputs { return self }
  public var outputs: PledgeAmountCellViewModelOutputs { return self }
}
