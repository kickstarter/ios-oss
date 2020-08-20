@testable import Kickstarter_Framework
@testable import KsApi
import Library
import PlaygroundSupport
import Prelude
import Prelude_UIKit
import UIKit

let project = .cosmicSurgery
  |> Project.lens.state .~ .failed
  |> Project.lens.dates.deadline .~ (NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 2)
  |> Project.lens.stats.staticUsdRate .~ 1.32
  |> Project.lens.rewardData.rewards .~ [Project.cosmicSurgery.rewards.last! |> Reward.lens.remaining .~ 0]
//  |> Project.lens.personalization.isBacking .~ true
//  |> Project.lens.personalization.backing %~~ { _, project in
//    .template
//      |> Backing.lens.rewardId .~ project.rewards.first?.id
//      |> Backing.lens.reward .~ project.rewards.first
// }

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchProjectResponse: project
  ),
  config: .template |> Config.lens.countryCode .~ "US",
  language: .en,
  mainBundle: Bundle.framework
)

initialize()
let controller = ProjectPamphletViewController.configuredWith(projectOrParam: .left(project), refTag: nil)

let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

let frame = parent.view.frame |> CGRect.lens.size.height .~ 1_800
PlaygroundPage.current.liveView = parent
parent.view.frame = frame
