@testable import Kickstarter_Framework
import Library
import XCTest

internal final class LoginToutViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  func testLoginToutView() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let intents = [LoginIntent.generic, .starProject, .messageCreator, .backProject]

    combos(Language.allLanguages, devices, intents).forEach { language, device, intent in
      withEnvironment(language: language) {
        let controller = LoginToutViewController.configuredWith(loginIntent: intent)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "intent_\(intent)_lang_\(language)_device_\(device)")
      }
    }
  }

  func testScrollToTop() {
    let intent = LoginIntent.generic
    let controller = LoginToutViewController.configuredWith(loginIntent: intent)

    // Due to the new design, a background imageView is now added as subview before the scroll.
    XCTAssertNotNil(controller.view.subviews[1] as? UIScrollView)
  }
}
