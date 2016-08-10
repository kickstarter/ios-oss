@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(),
  config: Config.template |> Config.lens.countryCode .~ "US",
  mainBundle: NSBundle.framework,
  language: .en
)

let project = Project.cosmicSurgery
  |> Project.lens.stats.staticUsdRate .~ 1.32
  |> Project.lens.personalization.isBacking .~ true
  |> Project.lens.personalization.backing .~ (
    .template |> Backing.lens.rewardId .~ 1
  )

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchProjectResponse: project
  )
)

let controller = storyboard(named: "ProjectMagazine")
  .instantiateViewControllerWithIdentifier("RewardsViewController") as! RewardsViewController
controller.configureWith(project: project)
controller.transfer(headerView: UIView(), previousContentOffset: nil)

let (parent, _) = playgroundControllers(device: .phone4inch, orientation: .landscape, child: controller)

let frame = parent.view.frame |> CGRect.lens.size.height .~ 1_000
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
