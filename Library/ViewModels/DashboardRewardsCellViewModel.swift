import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public struct RewardsRowData {
  public let country: Project.Country
  public let rewardsStats: [ProjectStatsEnvelope.RewardStats]
  public let totalPledged: Int
}

extension RewardsRowData: Equatable {}
public func == (lhs: RewardsRowData, rhs: RewardsRowData) -> Bool {
  return
    lhs.country == rhs.country &&
    lhs.rewardsStats == rhs.rewardsStats &&
    lhs.totalPledged == rhs.totalPledged
}

public protocol DashboardRewardsCellViewModelInputs {
  /// Call when Backers button is tapped.
  func backersButtonTapped()

  /// Call when load cell with project.
  func configureWith(rewardStats rewardStats: [ProjectStatsEnvelope.RewardStats],
                                 project: Project)

  /// Call when Pledged button is tapped.
  func pledgedButtonTapped()

  /// Call when See all tiers button is tapped.
  func seeAllTiersButtonTapped()

  /// Call when Top Rewards button is tapped.
  func topRewardsButtonTapped()
}

public protocol DashboardRewardsCellViewModelOutputs {
  /// Emits when should hide See all tiers button.
  var hideSeeAllTiersButton: Signal<Bool, NoError> { get }

  /// Emits when should notify the delegate that reward rows have been added to the stack view.
  var notifyDelegateAddedRewardRows: Signal<Void, NoError> { get }

  /// Emits RewardsRowData. Rewards array is truncated if 'see all' button is present.
  var rewardsRowData: Signal<RewardsRowData, NoError> { get }
}

public protocol DashboardRewardsCellViewModelType {
  var inputs: DashboardRewardsCellViewModelInputs { get }
  var outputs: DashboardRewardsCellViewModelOutputs { get }
}

public final class DashboardRewardsCellViewModel: DashboardRewardsCellViewModelType,
  DashboardRewardsCellViewModelInputs, DashboardRewardsCellViewModelOutputs {
  // swiftlint:disable function_body_length
  public init() {
    let statsProject = self.statsProjectProperty.signal.ignoreNil()

    let rewards = statsProject
      .map { stats, project in (project.rewards ?? [], stats) }
      .map(allRewardsStats(rewards:stats:))

    let initialSort = rewards.sort { $0.pledged > $1.pledged }

    let sortedByTop = rewards
      .sort { $0.minimum > $1.minimum }
      .takeWhen(self.topRewardsButtonTappedProperty.signal)

    let sortedByBackers = rewards
      .takeWhen(self.backersButtonTappedProperty.signal)
      .sort { $0.backersCount > $1.backersCount }

    let sortedByPledged = initialSort
      .takeWhen(self.pledgedButtonTappedProperty.signal)

    let allRewards = Signal.merge(
      initialSort,
      sortedByTop,
      sortedByBackers,
      sortedByPledged
    )

    let allRewardsRowData = combineLatest(
      statsProject.map { $1 },
      allRewards
      )
      .map { project, stats in
        RewardsRowData(country: project.country, rewardsStats: stats, totalPledged: project.stats.pledged)
    }

    let allTiersButtonIsHidden = Signal.merge(
      rewards.map { $0.count < 5 },
      seeAllTiersButtonTappedProperty.signal.mapConst(true)
    )

    self.hideSeeAllTiersButton = allTiersButtonIsHidden.skipRepeats()

    // if more than 6 rewards, truncate at 4
    self.rewardsRowData = combineLatest(allRewardsRowData, allTiersButtonIsHidden)
      .map { rowData, isHidden in
        let rewardCount = rowData.rewardsStats.count
        let maxRewards = isHidden ? rowData.rewardsStats :
          Array(rowData.rewardsStats[0..<(min(3, rewardCount))])

        return RewardsRowData(country: rowData.country,
                            rewardsStats: maxRewards,
                            totalPledged: rowData.totalPledged)
    }
    .skipRepeats(==)

    self.notifyDelegateAddedRewardRows = self.seeAllTiersButtonTappedProperty.signal

    statsProject
      .map { $1 }
      .takeWhen(self.seeAllTiersButtonTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackDashboardSeeAllRewards(project: $0) }
  }
  // swiftlint:enable function_body_length

  public var inputs: DashboardRewardsCellViewModelInputs { return self }
  public var outputs: DashboardRewardsCellViewModelOutputs { return self }

  public let hideSeeAllTiersButton: Signal<Bool, NoError>
  public let notifyDelegateAddedRewardRows: Signal<Void, NoError>
  public let rewardsRowData: Signal<RewardsRowData, NoError>

  private let backersButtonTappedProperty = MutableProperty()
  public func backersButtonTapped() {
    backersButtonTappedProperty.value = ()
  }
  private let statsProjectProperty =
    MutableProperty<([ProjectStatsEnvelope.RewardStats], Project)?>(nil)
  public func configureWith(rewardStats rewardStats: [ProjectStatsEnvelope.RewardStats],
                                        project: Project) {
    self.statsProjectProperty.value = (rewardStats, project)
  }
  private let pledgedButtonTappedProperty = MutableProperty()
  public func pledgedButtonTapped() {
    pledgedButtonTappedProperty.value = ()
  }
  private let seeAllTiersButtonTappedProperty = MutableProperty()
  public func seeAllTiersButtonTapped() {
    seeAllTiersButtonTappedProperty.value = ()
  }
  private let topRewardsButtonTappedProperty = MutableProperty()
  public func topRewardsButtonTapped() {
    topRewardsButtonTappedProperty.value = ()
  }
}

private func allRewardsStats(rewards rewards: [Reward],
                                     stats: [ProjectStatsEnvelope.RewardStats]) ->
  [ProjectStatsEnvelope.RewardStats] {

    let statsIds = stats.map { $0.rewardId }

    let zeroPledgedStats = rewards.filter { !statsIds.contains($0.id) }
      .map {
        return .zero
          |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ $0.backersCount ?? 0
          |> ProjectStatsEnvelope.RewardStats.lens.id .~ $0.id
          |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ $0.minimum
    }

    return zeroPledgedStats + stats
}
