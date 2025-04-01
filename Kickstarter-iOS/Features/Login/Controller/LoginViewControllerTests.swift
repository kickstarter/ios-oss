import Foundation
@testable import Kickstarter_Framework
import Library
import SnapshotTesting

internal final class LoginViewControllerTests: TestCase {
  func testView() {
    orthogonalCombos(Language.allLanguages, [Device.pad, Device.phone4_7inch, Device.phone5_8inch]).forEach {
      language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(LoginViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image,
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
