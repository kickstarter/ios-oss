@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

let project = Project.cosmicSurgery
  |> Project.lens.stats.staticUsdRate .~ 1.32
  |> Project.lens.personalization.isBacking .~ true
  |> Project.lens.personalization.backing .~ (
    .template
      |> Backing.lens.reward .~ Project.cosmicSurgery.rewards.last
      |> Backing.lens.shippingAmount .~ 10
      |> Backing.lens.amount .~ 700
)

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchProjectResponse: project
  ),
  config: Config.template |> Config.lens.countryCode .~ "US",
  mainBundle: NSBundle.framework,
  language: .de
)

initialize()
let controller = RewardPledgeViewController
  .configuredWith(project: project , reward: project.rewards.last!)

let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

let frame = parent.view.frame |> CGRect.lens.size.height .~ 800
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
