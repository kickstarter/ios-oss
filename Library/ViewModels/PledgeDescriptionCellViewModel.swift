import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol PledgeDescriptionCellViewModelInputs {
  func configure(with data: (Project, Reward))
  func learnMoreTapped()
}

public protocol PledgeDescriptionCellViewModelOutputs {
  var configureRewardCardViewWithData: Signal<(Project, Either<Reward, Backing>), Never> { get }
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
  }

  private let configDataProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configure(with data: (Project, Reward)) {
    self.configDataProperty.value = data
  }

  private let learnMoreTappedProperty = MutableProperty(())
  public func learnMoreTapped() {
    self.learnMoreTappedProperty.value = ()
  }

  public let configureRewardCardViewWithData: Signal<(Project, Either<Reward, Backing>), Never>
  public let estimatedDeliveryText: Signal<String, Never>
  public let presentTrustAndSafety: Signal<Void, Never>

  public var inputs: PledgeDescriptionCellViewModelInputs { return self }
  public var outputs: PledgeDescriptionCellViewModelOutputs { return self }
}
