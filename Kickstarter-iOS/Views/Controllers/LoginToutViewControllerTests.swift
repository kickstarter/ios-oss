import Library
@testable import Kickstarter_Framework

internal final class LoginToutViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    self.recordMode = true
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }

  func testLoginToutView() {

    let devices = [Device.phone4_7inch, .phone4inch, .pad]
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
}
