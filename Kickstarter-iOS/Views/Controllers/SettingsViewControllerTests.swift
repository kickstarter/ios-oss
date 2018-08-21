import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SettingsViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView() {
    let currentUser = User.template

    Language.allLanguages.forEach { language in
      withEnvironment(apiService: MockService(fetchUserSelfResponse: currentUser),
                      currentUser: currentUser,
                      language: language) {
          let vc = SettingsViewController.instantiate()

          let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)")
      }
    }
  }
}
