@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchProjectStatsResponse: .template
      |> ProjectStatsEnvelope.lens.videoStats .~
      (
        .template
          |> ProjectStatsEnvelope.VideoStats.lens.externalCompletions .~ 50
          |> ProjectStatsEnvelope.VideoStats.lens.externalStarts .~ 212
          |> ProjectStatsEnvelope.VideoStats.lens.internalCompletions .~ 750
          |> ProjectStatsEnvelope.VideoStats.lens.internalStarts .~ 1000
      ),
    fetchProjectsResponse: [
      .cosmicSurgery
        |> Project.lens.memberData.lastUpdatePublishedAt .~ NSDate().timeIntervalSince1970
        |> Project.lens.memberData.unreadMessagesCount .~ 42
        |> Project.lens.memberData.unseenActivityCount .~ 1_299
        |> Project.lens.memberData.permissions .~ [.post]
    ]
  ),
  currentUser: Project.cosmicSurgery.creator
)

let controller = storyboard(named: "Dashboard")
  .instantiateViewControllerWithIdentifier("DashboardViewController") as! DashboardViewController

controller.bindViewModel()

XCPlaygroundPage.currentPage.liveView = controller
controller.view |> UIView.lens.frame.size.height .~ 1_250
