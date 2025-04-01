import Foundation
@testable import Kickstarter_Framework
import Library
import SnapshotTesting

internal final class FacebookConfirmationViewControllerTests: TestCase {
  func testView() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    orthogonalCombos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let controller = FacebookConfirmationViewController
          .configuredWith(facebookUserEmail: "hello@example.com", facebookAccessToken: "")
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
