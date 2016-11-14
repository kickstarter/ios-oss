import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

internal final class DashboardViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    let project = cosmicSurgery
      |> Project.lens.dates.launchedAt .~ self.dateType.init().timeIntervalSince1970 - 60 * 60 * 24 * 14
      |> Project.lens.dates.deadline .~ self.dateType.init().timeIntervalSince1970 + 60 * 60 * 24 * 14

    AppEnvironment.pushEnvironment(
      apiService: MockService(
        fetchProjectStatsResponse: .template
          |> ProjectStatsEnvelope.lens.cumulativeStats .~ cumulativeStats
          |> ProjectStatsEnvelope.lens.referralDistribution .~ referrerStats
          |> ProjectStatsEnvelope.lens.rewardDistribution .~ rewardStats
          |> ProjectStatsEnvelope.lens.videoStats .~ videoStats
          |> ProjectStatsEnvelope.lens.fundingDistribution .~ fundingStats,

        fetchProjectsResponse: [project]
      ),
      currentUser: project.creator,
      mainBundle: NSBundle.framework
    )

    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {

    combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
      withEnvironment(language: language) {
        let controller = DashboardViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        parent.view.frame.size.height = device == .pad ? 2_150 : 2_000

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }
}

private let rewards = (1...6).map {
  .template
    |> Reward.lens.backersCount .~ $0 * 5
    |> Reward.lens.id .~ $0
    |> Reward.lens.minimum .~ $0 * 4
}

private let externalReferrerStats = .template
  |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 5
  |> ProjectStatsEnvelope.ReferrerStats.lens.code .~ "direct"
  |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.25
  |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 25
  |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "Direct traffic"
  |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .external

private let internalReferrerStats = .template
  |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 10
  |> ProjectStatsEnvelope.ReferrerStats.lens.code .~ "search"
  |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.4
  |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 40
  |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "Search"
  |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`internal`

private let customReferrerStats = .template
  |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 25
  |> ProjectStatsEnvelope.ReferrerStats.lens.code .~ "dfg"
  |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.35
  |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 35
  |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "Dfg"
  |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`custom`

private let referrerStats = [externalReferrerStats, internalReferrerStats, customReferrerStats]

private let rewardStats = (1...6).map {
  .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ $0 * 5
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ $0
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ $0 * 4
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ ($0 * $0 * 4 * 5)
}

private let videoStats = .template
  |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 51
  |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 212
  |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 751
  |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 1000

private let cumulativeStats = .template
  |> ProjectStatsEnvelope.CumulativeStats.lens.pledged .~ rewardStats.reduce(0) { $0 + $1.pledged }
  |> ProjectStatsEnvelope.CumulativeStats.lens.averagePledge .~ 5

private let cosmicSurgery = .cosmicSurgery
  |> Project.lens.stats.pledged .~ cumulativeStats.pledged
  |> Project.lens.memberData.lastUpdatePublishedAt .~ 1477581146
  |> Project.lens.memberData.unreadMessagesCount .~ 42
  |> Project.lens.memberData.unseenActivityCount .~ 1_299
  |> Project.lens.memberData.permissions .~ [.post, .viewPledges]
  |> Project.lens.rewards .~ rewards

private let stats = [3_000, 4_000, 5_000, 7_000, 8_000, 13_000, 14_000, 15_000, 17_000, 18_000]

private let fundingStats = stats.enumerate().map { idx, pledged in
  .template
    |> ProjectStatsEnvelope.FundingDateStats.lens.cumulativePledged .~ pledged
    |> ProjectStatsEnvelope.FundingDateStats.lens.date
      .~ (cosmicSurgery.dates.launchedAt + NSTimeInterval(idx * 86_400))
}
