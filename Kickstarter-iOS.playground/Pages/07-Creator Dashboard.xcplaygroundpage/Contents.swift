@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(mainBundle: NSBundle.framework, language: .en)

let rewards = (1...6).map {
  .template
    |> Reward.lens.backersCount .~ $0 * 5
    |> Reward.lens.id .~ $0
    |> Reward.lens.minimum .~ $0 * 4
}

let externalReferrerStats = (1...3).map {
  .template
    |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ $0 * 5
    |> ProjectStatsEnvelope.ReferrerStats.lens.code .~ "direct"
    |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.01
    |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 2
    |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "Direct traffic"
    |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .external
}
let internalReferrerStats = (1...3).map {
  .template
    |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ $0 * 10
    |> ProjectStatsEnvelope.ReferrerStats.lens.code .~ "search"
    |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.3
    |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 3
    |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "Search"
    |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`internal`
}
let customReferrerStats = (1...3).map {
  .template
    |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ $0 * 10
    |> ProjectStatsEnvelope.ReferrerStats.lens.code .~ "search"
    |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.01
    |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 3
    |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "Search"
    |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`custom`
}

let referrerStats = externalReferrerStats + internalReferrerStats + customReferrerStats

let rewardStats = (1...6).map {
  .template
    |> ProjectStatsEnvelope.RewardStats.lens.backersCount .~ $0 * 5
    |> ProjectStatsEnvelope.RewardStats.lens.id .~ $0
    |> ProjectStatsEnvelope.RewardStats.lens.minimum .~ $0 * 4
    |> ProjectStatsEnvelope.RewardStats.lens.pledged .~ ($0 * $0 * 4 * 5)
}

let videoStats = .template
  |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 51
  |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 212
  |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 751
  |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 1000

let cumulativeStats = .template
  |> ProjectStatsEnvelope.Cumulative.lens.pledged .~ rewardStats.reduce(0) { $0 + $1.pledged }

let cosmicSurgery = .cosmicSurgery |> Project.lens.stats.pledged .~ cumulativeStats.pledged

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchProjectStatsResponse: .template
      |> ProjectStatsEnvelope.lens.cumulative .~ cumulativeStats
      |> ProjectStatsEnvelope.lens.rewardStats .~ rewardStats
      |> ProjectStatsEnvelope.lens.referrerStats .~ referrerStats
      |> ProjectStatsEnvelope.lens.videoStats .~ videoStats,

    fetchProjectsResponse: [
      cosmicSurgery
        |> Project.lens.memberData.lastUpdatePublishedAt .~ NSDate().timeIntervalSince1970
        |> Project.lens.memberData.unreadMessagesCount .~ 42
        |> Project.lens.memberData.unseenActivityCount .~ 1_299
        |> Project.lens.memberData.permissions .~ [.post]
        |> Project.lens.rewards .~ rewards
    ]
  ),
  currentUser: cosmicSurgery.creator
)

let controller = storyboard(named: "Dashboard")
  .instantiateViewControllerWithIdentifier("DashboardViewController") as! DashboardViewController

XCPlaygroundPage.currentPage.liveView = controller
controller.view |> UIView.lens.frame.size.height .~ 1_250
