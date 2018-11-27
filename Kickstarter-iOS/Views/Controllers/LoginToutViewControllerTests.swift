import Library
@testable import Kickstarter_Framework
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
    let intents = [LoginIntent.generic, .starProject, .messageCreator, .backProject, .liveStreamSubscribe]

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

    XCTAssertNotNil(controller.view.subviews.first as? UIScrollView)
  }
}
