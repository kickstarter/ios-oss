@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class TwoFactorViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  func testView() {
    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(TwoFactorViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(matching: parent.view, as: .image, named: "lang_\(language)_device_\(device)")
      }
    }
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    super.tearDown()
  }
}
