@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let project = .template
  |> Project.lens.video .~ (
    .template
      |> Project.Video.lens.high .~ "https://d2pq0u4uni88oo.cloudfront.net/projects/1846844/video-562464-h264_high.mp4"
)

AppEnvironment.replaceCurrentEnvironment(
  mainBundle: NSBundle.framework,
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef")
  )
)

initialize()
let controller = Storyboard.Video.instantiate(VideoViewController)
controller.configureWith(project: project)

XCPlaygroundPage.currentPage.liveView = controller
