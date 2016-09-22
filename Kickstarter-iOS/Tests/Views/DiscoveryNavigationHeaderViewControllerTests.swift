@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import Result
import XCTest

// swiftlint:disable type_name
internal final class DiscoveryNavigationHeaderViewControllerTests: TestCase {
// swiftlint:ensable type_name

  let initialParams = .defaults
    |> DiscoveryParams.lens.staffPicks .~ true
    |> DiscoveryParams.lens.includePOTD .~ true

  let cultureParams = .defaults |> DiscoveryParams.lens.category .~ .art
  let storyParams = .defaults |> DiscoveryParams.lens.category .~ .filmAndVideo
  let entertainmentParams = .defaults |> DiscoveryParams.lens.category .~ .games
  let cultureSubParams = .defaults |> DiscoveryParams.lens.category .~ .illustration
  let storySubParams = .defaults |> DiscoveryParams.lens.category .~ .documentary
  let entertainmentSubParams = .defaults |> DiscoveryParams.lens.category .~ .tabletopGames

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: NSBundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
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

  func testDiscoveryNavigationHeaderView_Culture_All() {
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

  func testDiscoveryNavigationHeaderView_Story() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: storyParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Entertainment() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: entertainmentParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Culture_Subcategory() {
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

  func testDiscoveryNavigationHeaderView_Story_Subcategory() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: storySubParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Entertainment_Subcategory() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: entertainmentSubParams)

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

  func testDiscoveryNavigationHeaderView_Culture_All_iPad() {
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

  func testDiscoveryNavigationHeaderView_Story_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: storyParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Entertainment_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: entertainmentParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Culture_Subcategory_iPad() {
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

  func testDiscoveryNavigationHeaderView_Story_Subcategory_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: storySubParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }

  func testDiscoveryNavigationHeaderView_Entertainment_Subcategory_iPad() {
    Language.allLanguages.forEach { language in
      withEnvironment(language: language) {
        let controller = DiscoveryNavigationHeaderViewController.instantiate()
        let (parent, _) = traitControllers(device: .pad, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 65

        controller.viewDidLoad()
        controller.configureWith(params: entertainmentSubParams)

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }
}
