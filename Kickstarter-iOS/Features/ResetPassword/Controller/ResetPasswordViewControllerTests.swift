import Foundation
@testable import Kickstarter_Framework
import Library
import SnapshotTesting

internal final class ResetPasswordViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
  }

  func testView() {
    orthogonalCombos(Language.allLanguages, [Device.pad, Device.phone4_7inch, Device.phone5_8inch]).forEach {
      language, device in
      withEnvironment(language: language) {
        let controller = ResetPasswordViewController.configuredWith(email: "americasnexttopmodulus@gmail.com")
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
