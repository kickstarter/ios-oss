import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeAmountCellViewModelInputs {
  func configureWith(project: Project, reward: Reward)
}

public protocol PledgeAmountCellViewModelOutputs {
  var amount: Signal<String, Never> { get }
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

    self.currency = project
      .map { currencySymbol(forCountry: $0.country).trimmed() }
  }

  private let projectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.projectAndRewardProperty.value = (project, reward)
  }

  public let amount: Signal<String, Never>
  public let currency: Signal<String, Never>

  public var inputs: PledgeAmountCellViewModelInputs { return self }
  public var outputs: PledgeAmountCellViewModelOutputs { return self }
}
