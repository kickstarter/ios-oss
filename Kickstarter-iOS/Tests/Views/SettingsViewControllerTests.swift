import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SettingsViewControllerTests: TestCase {

  func testView() {
    let currentUser = .template |> User.lens.stats.backedProjectsCount .~ 1234

    Language.allLanguages.forEach { language in
      withEnvironment(currentUser: currentUser, language: language, mainBundle: NSBundle.framework) {

        let vc = SettingsViewController.instantiate()
        let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
        parent.view.frame.size.height = 1_450

        FBSnapshotVerifyView(vc.view, identifier: "Settings - \(language)")
      }
    }
  }
}
