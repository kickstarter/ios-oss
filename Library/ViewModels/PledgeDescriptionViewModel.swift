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
  var estimatedDeliveryStackViewIsHidden: Signal<Bool, Never> { get }
  var estimatedDeliveryText: Signal<String, Never> { get }
  var popViewController: Signal<(), Never> { get }
  var presentTrustAndSafety: Signal<Void, Never> { get }
  var rewardTitle: Signal<String, Never> { get }
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

    self.estimatedDeliveryStackViewIsHidden = self.configDataProperty.signal
      .skipNil()
      .map(second)
      .map { $0.estimatedDeliveryOn.isNil }

    self.presentTrustAndSafety = self.learnMoreTappedProperty.signal
    self.rewardTitle = self.configDataProperty.signal
      .skipNil()
      .map { _, reward in reward.title ?? Strings.Back_it_because_you_believe_in_it() }

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

  public let estimatedDeliveryStackViewIsHidden: Signal<Bool, Never>
  public let estimatedDeliveryText: Signal<String, Never>
  public let popViewController: Signal<(), Never>
  public let presentTrustAndSafety: Signal<Void, Never>
  public let rewardTitle: Signal<String, Never>

  public var inputs: PledgeDescriptionViewModelInputs { return self }
  public var outputs: PledgeDescriptionViewModelOutputs { return self }
}
