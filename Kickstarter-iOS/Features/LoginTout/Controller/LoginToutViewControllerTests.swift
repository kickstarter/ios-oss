@testable import Kickstarter_Framework
import Library
import SnapshotTesting
import XCTest

internal final class LoginToutViewControllerTests: TestCase {
  func testLoginToutView() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let intents = [LoginIntent.generic, .starProject, .messageCreator, .backProject]

    orthogonalCombos(Language.allLanguages, devices, intents).forEach { language, device, intent in
      withEnvironment(language: language) {
        let controller = LoginToutViewController.configuredWith(loginIntent: intent)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "intent_\(intent)_lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testLoginToutView_NewDesignSystem_On() {
    let languages = [Language.en]
    let devices = [Device.phone4_7inch]
    let intents = [LoginIntent.generic]

    let remoteConfig = MockRemoteConfigClient()
    remoteConfig.features = [
      RemoteConfigFeature.newDesignSystem.rawValue: true
    ]

    orthogonalCombos(languages, devices, intents).forEach { language, device, intent in
      withEnvironment(language: language, remoteConfigClient: remoteConfig) {
        let controller = LoginToutViewController.configuredWith(loginIntent: intent)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "intent_\(intent)_lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testDarkMode() {
    let darkModeOn = MockRemoteConfigClient()
    darkModeOn.features = [
      RemoteConfigFeature.newDesignSystem.rawValue: true
    ]

    let language = Language.en
    let device = Device.phone5_8inch
    let resolver = AppColorResolver()
    let intent = LoginIntent.generic

    withEnvironment(colorResolver: resolver, language: language, remoteConfigClient: darkModeOn) {
      let controller = LoginToutViewController.configuredWith(loginIntent: intent)
      let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

      controller.overrideUserInterfaceStyle = .dark

      self.scheduler.run()

      assertSnapshot(
        matching: parent.view,
        as: .image,
        named: "intent_\(intent)_lang_\(language)_device_\(device)_dark"
      )
    }
  }

  func testScrollToTop() {
    let intent = LoginIntent.generic
    let controller = LoginToutViewController.configuredWith(loginIntent: intent)

    // Due to the new design, a background imageView is now added as subview before the scroll.
    XCTAssertNotNil(controller.view.subviews[1] as? UIScrollView)
  }
}
