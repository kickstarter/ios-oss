@testable import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit
import XCPlayground
@testable import Kickstarter_Framework

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(),
  mainBundle: NSBundle.framework,
  language: .en
) 

let project = Project.cosmicSurgery
  |> Project.lens.state .~ .successful
  |> Project.lens.personalization.isBacking .~ true
  |> Project.lens.stats.backersCount .~ 1_234
  |> Project.lens.dates.deadline .~ NSDate().timeIntervalSince1970 + 60 * 60 * 24 * 2
  |> Project.lens.stats.pledged .~ 12_345
  |> Project.lens.stats.goal .~ 123_456
  |> Project.lens.stats.commentsCount .~ 1_366
  |> Project.lens.stats.updatesCount .~ 12

AppEnvironment.replaceCurrentEnvironment(
  apiService: MockService(
    oauthToken: OauthToken(token: "deadbeef"),
    fetchProjectResponse: project
  ),
  config: .template |> Config.lens.countryCode .~ "US"
)

initialize()
let controller = ProjectMagazineViewController.configuredWith(projectOrParam: .left(project), refTag: nil)

let (parent, _) = playgroundControllers(device: .phone4_7inch, orientation: .portrait, child: controller)

let frame = parent.view.frame //|> CGRect.lens.size.height .~ 1_200
XCPlaygroundPage.currentPage.liveView = parent
parent.view.frame = frame
