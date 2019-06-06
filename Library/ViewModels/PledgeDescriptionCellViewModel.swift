import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeDescriptionCellViewModelInputs {
  func configureWith(reward: Reward)
  func learnMoreTapped()
}

public protocol PledgeDescriptionCellViewModelOutputs {
  var estimatedDeliveryText: Signal<String, Never> { get }
  var presentTrustAndSafety: Signal<Void, Never> { get }
}

public protocol PledgeDescriptionCellViewModelType {
  var inputs: PledgeDescriptionCellViewModelInputs { get }
  var outputs: PledgeDescriptionCellViewModelOutputs { get }
}

public final class PledgeDescriptionCellViewModel: PledgeDescriptionCellViewModelType,
  PledgeDescriptionCellViewModelInputs, PledgeDescriptionCellViewModelOutputs {
  public init() {
    self.estimatedDeliveryText = self.rewardProperty.signal
      .skipNil()
      .map { $0.estimatedDeliveryOn }
      .skipNil()
      .map { Format.date(secondsInUTC: $0, template: DateFormatter.monthYear, timeZone: UTCTimeZone) }

    self.presentTrustAndSafety = self.learnMoreTappedProperty.signal
  }

  private let rewardProperty = MutableProperty<Reward?>(nil)
  public func configureWith(reward: Reward) {
    self.rewardProperty.value = reward
  }

  private let learnMoreTappedProperty = MutableProperty(())
  public func learnMoreTapped() {
    self.learnMoreTappedProperty.value = ()
  }

  public let estimatedDeliveryText: Signal<String, Never>
  public let presentTrustAndSafety: Signal<Void, Never>

  public var inputs: PledgeDescriptionCellViewModelInputs { return self }
  public var outputs: PledgeDescriptionCellViewModelOutputs { return self }
}
