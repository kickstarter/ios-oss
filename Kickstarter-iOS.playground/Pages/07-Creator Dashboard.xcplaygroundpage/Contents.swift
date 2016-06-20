@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    fetchProjectsResponse: [
      .cosmicSurgery
        |> Project.lens.creatorData.lastUpdatePublishedAt .~ NSDate().timeIntervalSince1970
        |> Project.lens.creatorData.unreadMessagesCount .~ 42
        |> Project.lens.creatorData.unseenActivityCount .~ 1_299
    ]
  )
)

let controller = storyboard(named: "Dashboard")
  .instantiateViewControllerWithIdentifier("DashboardViewController") as! DashboardViewController

controller.bindViewModel()

XCPlaygroundPage.currentPage.liveView = controller
controller.view |> UIView.lens.frame.size.height .~ 1_250
