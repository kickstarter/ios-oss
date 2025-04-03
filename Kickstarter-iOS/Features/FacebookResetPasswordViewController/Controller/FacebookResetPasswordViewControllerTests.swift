import Foundation
@testable import Kickstarter_Framework
import Library
import SnapshotTesting

internal final class FacebookResetPasswordViewControllerTests: TestCase {
  func testFacebookResetPasswordViewController() {
    let devices = [Device.phone4_7inch, Device.pad]
    orthogonalCombos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = FacebookResetPasswordViewController.instantiate()
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

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
