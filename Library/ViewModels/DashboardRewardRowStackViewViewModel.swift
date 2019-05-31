import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol DashboardRewardRowStackViewViewModelInputs {
  /// Call to configure view model with Country, RewardsStats, and total pledged.
  func configureWith(
    country: Project.Country,
    reward: ProjectStatsEnvelope.RewardStats,
    totalPledged: Int
  )
}

public protocol DashboardRewardRowStackViewViewModelOutputs {
  /// Emits string for backer text label.
  var backersText: Signal<String, Never> { get }

  /// Emits string for pledged text label.
  var pledgedText: Signal<String, Never> { get }

  /// Emits string for top rewards text label.
  var topRewardText: Signal<String, Never> { get }
}

public protocol DashboardRewardRowStackViewViewModelType {
  var inputs: DashboardRewardRowStackViewViewModelInputs { get }
  var outputs: DashboardRewardRowStackViewViewModelOutputs { get }
}

public final class DashboardRewardRowStackViewViewModel: DashboardRewardRowStackViewViewModelType,
  DashboardRewardRowStackViewViewModelInputs, DashboardRewardRowStackViewViewModelOutputs {
  public init() {
    let countryRewardPledged = self.countryRewardPledgedProperty.signal.skipNil()

    self.backersText = countryRewardPledged.map { _, reward, _ in
      Format.wholeNumber(reward.backersCount)
    }

    self.pledgedText = countryRewardPledged.map(pledgedWithPercentText)

    self.topRewardText = countryRewardPledged
      .map { country, reward, _ in
        reward.rewardId == Reward.noReward.id
          ? Strings.dashboard_graphs_rewards_no_reward()
          : Format.currency(reward.minimum ?? 0, country: country)
      }
  }

  public var inputs: DashboardRewardRowStackViewViewModelInputs { return self }
  public var outputs: DashboardRewardRowStackViewViewModelOutputs { return self }

  public let backersText: Signal<String, Never>
  public let pledgedText: Signal<String, Never>
  public let topRewardText: Signal<String, Never>

  fileprivate let countryRewardPledgedProperty =
    MutableProperty<(Project.Country, ProjectStatsEnvelope.RewardStats, Int)?>(nil)
  public func configureWith(
    country: Project.Country,
    reward: ProjectStatsEnvelope.RewardStats,
    totalPledged: Int
  ) {
    self.countryRewardPledgedProperty.value = (country, reward, totalPledged)
  }
}

private func pledgedWithPercentText(
  country: Project.Country,
  reward: ProjectStatsEnvelope.RewardStats,
  totalPledged: Int
) -> String {
  let percent = Double(reward.pledged) / Double(totalPledged)
  let percentText = (percent > 0.01 || percent == 0) ? Format.percentage(percent) : "<1%"
  return Format.currency(reward.pledged, country: country) + " (\(percentText))"
}
