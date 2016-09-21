import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol DashboardRewardRowStackViewViewModelInputs {
  /// Call to configure view model with Country, RewardsStats, and total pledged.
  func configureWith(country country: Project.Country,
                             reward: ProjectStatsEnvelope.RewardStats,
                             totalPledged: Int)
}

public protocol DashboardRewardRowStackViewViewModelOutputs {
  /// Emits string for backer text label.
  var backersText: Signal<String, NoError> { get }

  /// Emits string for pledged text label.
  var pledgedText: Signal<String, NoError> { get }

  /// Emits string for top rewards text label.
  var topRewardText: Signal<String, NoError> { get }
}

public protocol DashboardRewardRowStackViewViewModelType {
  var inputs: DashboardRewardRowStackViewViewModelInputs { get }
  var outputs: DashboardRewardRowStackViewViewModelOutputs { get }
}

public final class DashboardRewardRowStackViewViewModel: DashboardRewardRowStackViewViewModelType,
  DashboardRewardRowStackViewViewModelInputs, DashboardRewardRowStackViewViewModelOutputs {

  public init() {
    let countryRewardPledged = self.countryRewardPledgedProperty.signal.ignoreNil()

    self.backersText = countryRewardPledged.map { _, reward, _ in
      Format.wholeNumber(reward.backersCount ?? 0)
    }

    self.pledgedText = countryRewardPledged.map(pledgedWithPercentText)

    self.topRewardText = countryRewardPledged
      .map { country, reward, _ in
        reward.rewardId == Reward.noReward.id
          ? Strings.dashboard_graphs_rewards_no_reward()
          : Format.currency(reward.minimum, country: country)
    }
  }

  public var inputs: DashboardRewardRowStackViewViewModelInputs { return self }
  public var outputs: DashboardRewardRowStackViewViewModelOutputs { return self }

  public let backersText: Signal<String, NoError>
  public let pledgedText: Signal<String, NoError>
  public let topRewardText: Signal<String, NoError>

  private let countryRewardPledgedProperty =
    MutableProperty<(Project.Country, ProjectStatsEnvelope.RewardStats, Int)?>(nil)
  public func configureWith(country country: Project.Country,
                                    reward: ProjectStatsEnvelope.RewardStats,
                                    totalPledged: Int) {
    countryRewardPledgedProperty.value = (country, reward, totalPledged)
  }
}

private func pledgedWithPercentText(country country: Project.Country,
                                            reward: ProjectStatsEnvelope.RewardStats,
                                            totalPledged: Int) -> String {
    let percent = Double(reward.pledged) / Double(totalPledged)
    let percentText = (percent > 0.01 || percent == 0) ? Format.percentage(percent) : "<1%"
    return Format.currency(reward.pledged, country: country) + " (\(percentText))"
}
