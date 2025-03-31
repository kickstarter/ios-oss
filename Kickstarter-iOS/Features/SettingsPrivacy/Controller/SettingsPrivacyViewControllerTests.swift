@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class SettingsPrivacyViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testSocialOptedOut() {
    let currentUser = User.template
      |> \.social .~ false

    let mockService = MockService(
      fetchUserSelfResponse: currentUser
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: currentUser,
        language: language
      ) {
        let vc = Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testSocialOptedIn() {
    let currentUser = User.template
      |> \.social .~ true

    let mockService = MockService(
      fetchUserSelfResponse: currentUser
    )

    combos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: currentUser,
        language: language
      ) {
        let vc = Storyboard.SettingsPrivacy.instantiate(SettingsPrivacyViewController.self)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: vc)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
