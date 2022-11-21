@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class SetYourPasswordViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  func testView() {
    combos([Language.en], [Device.phone4_7inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language) {
        let controller = SetYourPasswordViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }
}
