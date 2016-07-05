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

  /// Emits string for percent text label.
  var percentText: Signal<String, NoError> { get }

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

    self.percentText = countryRewardPledged
      .map { _, reward, totalPledged in
        let percent = Double(reward.pledged) / Double(totalPledged)
        return (percent > 0.01 || percent == 0) ? Format.percentage(percent) : "<1%"
    }

    self.pledgedText = countryRewardPledged
      .map { country, reward, _ in Format.currency(reward.pledged, country: country) }

    self.topRewardText = countryRewardPledged
      .map { country, reward, _ in
        return reward.rewardId == 0 ? Strings.dashboard_graphs_rewards_no_reward() :
          Format.currency(reward.minimum, country: country)
    }
  }

  public var inputs: DashboardRewardRowStackViewViewModelInputs { return self }
  public var outputs: DashboardRewardRowStackViewViewModelOutputs { return self }

  public let backersText: Signal<String, NoError>
  public let percentText: Signal<String, NoError>
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
