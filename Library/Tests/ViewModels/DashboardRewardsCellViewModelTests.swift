import XCTest
import Result
import Prelude
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardRewardsCellViewModelTests: TestCase {
  let vm: DashboardRewardsCellViewModelType = DashboardRewardsCellViewModel()

  let hideSeeAllTiersButton = TestObserver<Bool, NoError>()
  let notifyDelegateAddedRewardRows = TestObserver<Void, NoError>()
  let rewardsRowCountry = TestObserver<Project.Country, NoError>()
  let rewardsRowRewards = TestObserver<[ProjectStatsEnvelope.RewardStats], NoError>()
  let rewardsRowTotalPledged = TestObserver<Int, NoError>()

  let reward1 = Reward.template
  let reward2 = Reward.noReward
  let reward3 = Reward.template
    |> Reward.lens.backersCount .~ 120
    |> Reward.lens.id .~ 2
    |> Reward.lens.minimum .~ 20
  let reward4 = Reward.template
    |> Reward.lens.backersCount .~ 4
    |> Reward.lens.id .~ 3
    |> Reward.lens.minimum .~ 15
  let reward5 = Reward.template
    |> Reward.lens.backersCount .~ 25
    |> Reward.lens.id .~ 4
    |> Reward.lens.minimum .~ 35
  let reward6 = Reward.template
    |> Reward.lens.backersCount .~ 16
    |> Reward.lens.id .~ 5
    |> Reward.lens.minimum .~ 30
  let reward7 = Reward.template
    |> Reward.lens.id .~ 6
    |> Reward.lens.backersCount .~ 0
    |> Reward.lens.minimum .~ 100

  let stat1 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 1

  let stat2 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 120
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 2
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 20
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 1000

  let stat3 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 4
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 3
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 15
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 250

  let stat4 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 25
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 4
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 35
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 1750

  let stat5 = .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ 16
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 5
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 30
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ 1500

  let zeroPledgedStat1 = ProjectStatsEnvelope.RewardStats.unPledged
  let zeroPledgedStat2 = ProjectStatsEnvelope.RewardStats.unPledged
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ 6
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ 100

  override func setUp() {
    super.setUp()

    vm.outputs.hideSeeAllTiersButton.observe(hideSeeAllTiersButton.observer)
    vm.outputs.notifyDelegateAddedRewardRows.observe(notifyDelegateAddedRewardRows.observer)
    vm.outputs.rewardsRowData.map { $0.country }.observe(rewardsRowCountry.observer)
    vm.outputs.rewardsRowData.map { $0.rewardsStats }.observe(rewardsRowRewards.observer)
    vm.outputs.rewardsRowData.map { $0.totalPledged }.observe(rewardsRowTotalPledged.observer)
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

    self.rewardsRowRewards.assertValues([[stat2, stat1, zeroPledgedStat1]],
                                        "Emits initial reward stats sorted by minimum value")
    self.rewardsRowCountry.assertValues([.US])
    self.rewardsRowTotalPledged.assertValues([1500])
    self.hideSeeAllTiersButton.assertValues([true])

    //switched project
//    let rewards2 = [reward2, reward3, reward7]
//    let project2 = Project.template
//      |> Project.lens.rewards .~ rewards2
//      |> Project.lens.stats.pledged .~ 1_000
//    let stats2 = [stat2]
//
//    self.vm.inputs.configureWith(project: project2, rewardStats: stats2, totalPledged: 1000)
//
//    self.rewardsRowRewards.assertValues([[stat2, stat1, zeroPledgedStat1],
//      [zeroPledgedStat2, stat2, zeroPledgedStat1]])
//    self.rewardsRowCountry.assertValues([.US, .US])
//    self.rewardsRowTotalPledged.assertValues([1500, 1000])
//    self.hideSeeAllTiersButton.assertValues([true])
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

    self.rewardsRowRewards.assertValues([[stat4, stat5, stat2]],
                                        "Emits 4 initial rewards sorted by minimum value")

    self.rewardsRowCountry.assertValues([.US])
    self.rewardsRowTotalPledged.assertValues([5000])
    self.hideSeeAllTiersButton.assertValues([false])
    self.notifyDelegateAddedRewardRows.assertDidNotEmitValue("No additional rewards were added.")

    self.vm.inputs.seeAllTiersButtonTapped()

    self.rewardsRowRewards.assertValues([[stat4, stat5, stat2],
      [stat4, stat5, stat2, stat1, stat3, zeroPledgedStat1, zeroPledgedStat2]
    ], "Emit all rewards sorted by minimum value")
    self.rewardsRowCountry.assertValues([.US, .US])
    self.rewardsRowTotalPledged.assertValues([5000, 5000])
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

    self.rewardsRowRewards.assertValues([[stat4, stat5, stat2]],
                                        "Emits 4 initial rewards sorted by minimum value")
    self.vm.inputs.backersButtonTapped()

    self.rewardsRowRewards.assertValues([
      [stat4, stat5, stat2],
      [stat2, stat1, stat4]
    ],
    "Emits rewards sorted by backers count")

    self.vm.inputs.topRewardsButtonTapped()

    self.rewardsRowRewards.assertValues([
      [stat4, stat5, stat2],
      [stat2, stat1, stat4],
      [zeroPledgedStat2, stat4, stat5],
    ],
    "Emits rewards sorted by min value")

    self.vm.inputs.pledgedButtonTapped()

    self.rewardsRowRewards.assertValues([
      [stat4, stat5, stat2],
      [stat2, stat1, stat4],
      [zeroPledgedStat2, stat4, stat5],
      [stat4, stat5, stat2]
    ],
    "Emits rewards sorted by pledged count")
  }
}
