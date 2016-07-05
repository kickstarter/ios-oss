@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let rewards = (1...6).map {
  .template
    |> Reward.lens.backersCount .~ $0 * 5
    |> Reward.lens.id .~ $0
    |> Reward.lens.minimum .~ $0 * 4
}

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
  |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 750
  |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 1000

let cumulativeStats = .template
  |> ProjectStatsEnvelope.Cumulative.lens.pledged .~ rewardStats.reduce(0) { $0 + $1.pledged }

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchProjectStatsResponse: .template
      |> ProjectStatsEnvelope.lens.videoStats .~ videoStats
      |> ProjectStatsEnvelope.lens.cumulative .~ cumulativeStats
      |> ProjectStatsEnvelope.lens.rewardStats .~ rewardStats,
    fetchProjectsResponse: [
      .cosmicSurgery
        |> Project.lens.memberData.lastUpdatePublishedAt .~ NSDate().timeIntervalSince1970
        |> Project.lens.memberData.unreadMessagesCount .~ 42
        |> Project.lens.memberData.unseenActivityCount .~ 1_299
        |> Project.lens.memberData.permissions .~ [.post]
        |> Project.lens.rewards .~ rewards
    ]
  ),
  currentUser: Project.cosmicSurgery.creator
)

let controller = storyboard(named: "Dashboard")
  .instantiateViewControllerWithIdentifier("DashboardViewController") as! DashboardViewController

controller.bindViewModel()

controller.bindStyles()

XCPlaygroundPage.currentPage.liveView = controller
controller.view |> UIView.lens.frame.size.height .~ 1_250
