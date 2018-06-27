@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import PlaygroundSupport
@testable import Kickstarter_Framework

let project = .cosmicSurgery
  |> Project.lens.video .~ (
    .template
      |> Project.Video.lens.high .~ "https://d2pq0u4uni88oo.cloudfront.net/projects/1846844/video-562464-h264_high.mp4"
)

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef")
  ),
  mainBundle: Bundle.framework
)

initialize()
let controller = VideoViewController.configuredWith(project: project)

PlaygroundPage.current.liveView = controller
