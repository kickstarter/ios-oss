@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

internal final class DiscoveryNavigationHeaderViewControllerTests: TestCase {

  let initialParams = .defaults
    |> DiscoveryParams.lens.includePOTD .~ true

  let cultureParams = .defaults |> DiscoveryParams.lens.category .~ .art
  let storyParams = .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo
  let entertainmentParams = .defaults |> DiscoveryParams.lens.category .~ .games
  let cultureSubParams = .defaults |> DiscoveryParams.lens.category .~ .illustration
  let storySubParams = .defaults |> DiscoveryParams.lens.category .~ .documentary
  let entertainmentSubParams = .defaults |> DiscoveryParams.lens.category .~ .tabletopGames

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testDiscoveryNavigationHeaderView() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: initialParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Art_All() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: cultureParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Art_Subcategory() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: cultureSubParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: initialParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Art_All_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: cultureParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Art_Subcategory_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: cultureSubParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }
}
