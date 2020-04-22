@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class DashboardRewardsCellViewModelTests: TestCase {
  let vm: DashboardRewardsCellViewModelType = DashboardRewardsCellViewModel()

  let hideSeeAllTiersButton = TestObserver<Bool, Never>()
  let notifyDelegateAddedRewardRows = TestObserver<Void, Never>()
  let rewardsRowCountry = TestObserver<Project.Country, Never>()
  let rewardsRowRewards = TestObserver<[ProjectStatsEnvelope.RewardStats], Never>()
  let rewardsRowTotalPledged = TestObserver<Int, Never>()

  let reward1 = Reward.template
  let reward2 = Reward.noReward
  let reward3 = Reward.template
    |> Reward.lens.backersCount .~ 120
    |> Reward.lens.id .~ 2
    |> Reward.lens.minimum .~ 20.0
  let reward4 = Reward.template
    |> Reward.lens.backersCount .~ 4
    |> Reward.lens.id .~ 3
    |> Reward.lens.minimum .~ 15.0
  let reward5 = Reward.template
    |> Reward.lens.backersCount .~ 25
    |> Reward.lens.id .~ 4
    |> Reward.lens.minimum .~ 35.0
  let reward6 = Reward.template
    |> Reward.lens.backersCount .~ 16
    |> Reward.lens.id .~ 5
    |> Reward.lens.minimum .~ 30.0
  let reward7 = Reward.template
    |> Reward.lens.id .~ 6
    |> Reward.lens.backersCount .~ 0
    |> Reward.lens.minimum .~ 100.0

  let stat1 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 1

  let stat2 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 120
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 2
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 20.0
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 1_000

  let stat3 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 4
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 3
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 15.0
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 250

  let stat4 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 25
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 4
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 35.0
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 1_750

  let stat5 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 16
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 30.0
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 1_500

  let zeroPledgedStat1 = ProjectStatsEnvelope.RewardStats.unPledged
  let zeroPledgedStat2 = ProjectStatsEnvelope.RewardStats.unPledged
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 6
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 100.0

  override func setUp() {
    super.setUp()

    self.vm.outputs.hideSeeAllTiersButton.observe(self.hideSeeAllTiersButton.observer)
    self.vm.outputs.notifyDelegateAddedRewardRows.observe(self.notifyDelegateAddedRewardRows.observer)
    self.vm.outputs.rewardsRowData.map { $0.country }.observe(self.rewardsRowCountry.observer)
    self.vm.outputs.rewardsRowData.map { $0.rewardsStats }.observe(self.rewardsRowRewards.observer)
    self.vm.outputs.rewardsRowData.map { $0.totalPledged }.observe(self.rewardsRowTotalPledged.observer)
  }

  func testRewards() {
    let rewards = [reward1, reward2, reward3]
    let project = .template
      |> Project.lens.rewards .~ rewards
      |> Project.lens.stats.pledged .~ 1_500
    let stats = [stat1, stat2]

    self.rewardsRowRewards.assertValueCount(0)
    self.rewardsRowCountry.assertValueCount(0)
    self.rewardsRowTotalPledged.assertValueCount(0)
    self.hideSeeAllTiersButton.assertValueCount(0)

    self.vm.inputs.configureWith(rewardStats: stats, project: project)

    self.rewardsRowRewards.assertValues(
      [[self.stat2, self.stat1, self.zeroPledgedStat1]],
      "Emits initial reward stats sorted by minimum value"
    )
    self.rewardsRowCountry.assertValues([.us])
    self.rewardsRowTotalPledged.assertValues([1_500])
    self.hideSeeAllTiersButton.assertValues([true])
  }

  func testShowAllRewards() {
    let rewards = [reward1, reward2, reward3, reward4, reward5, reward6, reward7]
    let project = .template
      |> Project.lens.rewards .~ rewards
      |> Project.lens.stats.pledged .~ 5_000
    let stats = [stat1, stat2, stat3, stat4, stat5]

    self.rewardsRowRewards.assertValueCount(0)
    self.hideSeeAllTiersButton.assertValueCount(0)

    self.vm.inputs.configureWith(rewardStats: stats, project: project)

    self.rewardsRowRewards.assertValues(
      [[self.stat4, self.stat5, self.stat2]],
      "Emits 4 initial rewards sorted by minimum value"
    )

    self.rewardsRowCountry.assertValues([.us])
    self.rewardsRowTotalPledged.assertValues([5_000])
    self.hideSeeAllTiersButton.assertValues([false])
    self.notifyDelegateAddedRewardRows.assertDidNotEmitValue("No additional rewards were added.")

    self.vm.inputs.seeAllTiersButtonTapped()

    self.rewardsRowRewards.assertValues([
      [self.stat4, self.stat5, self.stat2],
      [
        self.stat4,
        self.stat5,
        self.stat2,
        self.stat1,
        self.stat3,
        self.zeroPledgedStat1,
        self.zeroPledgedStat2
      ]
    ], "Emit all rewards sorted by minimum value")
    self.rewardsRowCountry.assertValues([.us, .us])
    self.rewardsRowTotalPledged.assertValues([5_000, 5_000])
    self.hideSeeAllTiersButton.assertValues([false, true])
    self.notifyDelegateAddedRewardRows.assertValueCount(1, "Additional rewards were added.")
    XCTAssertEqual(["Showed All Rewards"], self.trackingClient.events)
  }

  func testSorting() {
    let rewards = [reward1, reward2, reward3, reward4, reward5, reward6, reward7]
    let project = Project.template |> Project.lens.rewards .~ rewards
    let stats = [stat1, stat2, stat3, stat4, stat5]

    self.rewardsRowRewards.assertValueCount(0)
    self.hideSeeAllTiersButton.assertValueCount(0)

    self.vm.inputs.configureWith(rewardStats: stats, project: project)

    self.rewardsRowRewards.assertValues(
      [[self.stat4, self.stat5, self.stat2]],
      "Emits 4 initial rewards sorted by minimum value"
    )
    self.vm.inputs.backersButtonTapped()

    self.rewardsRowRewards.assertValues(
      [
        [self.stat4, self.stat5, self.stat2],
        [self.stat2, self.stat1, self.stat4]
      ],
      "Emits rewards sorted by backers count"
    )

    self.vm.inputs.topRewardsButtonTapped()

    self.rewardsRowRewards.assertValues(
      [
        [self.stat4, self.stat5, self.stat2],
        [self.stat2, self.stat1, self.stat4],
        [self.zeroPledgedStat2, self.stat4, self.stat5]
      ],
      "Emits rewards sorted by min value"
    )

    self.vm.inputs.pledgedButtonTapped()

    self.rewardsRowRewards.assertValues(
      [
        [self.stat4, self.stat5, self.stat2],
        [self.stat2, self.stat1, self.stat4],
        [self.zeroPledgedStat2, self.stat4, self.stat5],
        [self.stat4, self.stat5, self.stat2]
      ],
      "Emits rewards sorted by pledged count"
    )
  }
}
