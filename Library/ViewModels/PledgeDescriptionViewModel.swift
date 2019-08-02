import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeDescriptionViewModelInputs {
  func configureWith(data: (Project, Reward))
  func learnMoreTapped()
  func rewardCardTapped()
}

public protocol PledgeDescriptionViewModelOutputs {
  var configureRewardCardViewWithData: Signal<(Project, Either<Reward, Backing>), Never> { get }
  var estimatedDeliveryText: Signal<String, Never> { get }
  var popViewController: Signal<(), Never> { get }
  var presentTrustAndSafety: Signal<Void, Never> { get }
}

public protocol PledgeDescriptionViewModelType {
  var inputs: PledgeDescriptionViewModelInputs { get }
  var outputs: PledgeDescriptionViewModelOutputs { get }
}

public final class PledgeDescriptionViewModel: PledgeDescriptionViewModelType,
  PledgeDescriptionViewModelInputs, PledgeDescriptionViewModelOutputs {
  public init() {
    self.estimatedDeliveryText = self.configDataProperty.signal
      .skipNil()
      .map(second)
      .map { $0.estimatedDeliveryOn }
      .skipNil()
      .map { Format.date(secondsInUTC: $0, template: DateFormatter.monthYear, timeZone: UTCTimeZone) }

    self.presentTrustAndSafety = self.learnMoreTappedProperty.signal
    self.configureRewardCardViewWithData = self.configDataProperty.signal
      .skipNil()
      .map { project, reward in (project, .init(left: reward)) }

    self.popViewController = self.rewardCardTappedSignal
  }

  private let configDataProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(data: (Project, Reward)) {
    self.configDataProperty.value = data
  }

  private let learnMoreTappedProperty = MutableProperty(())
  public func learnMoreTapped() {
    self.learnMoreTappedProperty.value = ()
  }

  private let (rewardCardTappedSignal, rewardCardTappedObserver) = Signal<(), Never>.pipe()
  public func rewardCardTapped() {
    self.rewardCardTappedObserver.send(value: ())
  }

  public let configureRewardCardViewWithData: Signal<(Project, Either<Reward, Backing>), Never>
  public let estimatedDeliveryText: Signal<String, Never>
  public let popViewController: Signal<(), Never>
  public let presentTrustAndSafety: Signal<Void, Never>

  public var inputs: PledgeDescriptionViewModelInputs { return self }
  public var outputs: PledgeDescriptionViewModelOutputs { return self }
}
