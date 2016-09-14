import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class RewardsViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()

    let currentUser = .template |> User.lens.stats.backedProjectsCount .~ 1234

    AppEnvironment.pushEnvironment(currentUser: currentUser, mainBundle: NSBundle.framework)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testView() {
    let countries = ["US", "GB", "FR"]
    let languages = Language.allLanguages

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

    combos(languages, countries).forEach { language, country in
      withEnvironment(config: .template |> Config.lens.countryCode .~ country, language: language) {

        let rewards = Storyboard.ProjectMagazine.instantiate(RewardsViewController)
        rewards.configureWith(project: project)
        rewards.transfer(headerView: UIView(), previousContentOffset: nil)

        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: rewards)
        parent.view.frame.size.height = 1_250

        FBSnapshotVerifyView(parent.view, identifier: "Rewards - \(language) - \(country)")
      }
    }
  }
}
