import Library
@testable import Kickstarter_Framework

internal final class SignupViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  func testView() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = SignupViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }
}
