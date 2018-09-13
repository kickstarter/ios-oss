import Library
import Prelude
import Result
import XCTest
@testable import Kickstarter_Framework
@testable import KsApi

internal final class SettingsAccountViewControllerTests: TestCase {

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

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: MockService(fetchUserSelfResponse: currentUser),
          currentUser: currentUser,
          language: language) {

            let vc = SettingsAccountViewController.instantiate()
            let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

            self.scheduler.run()

            FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
        }
    }
  }
}
