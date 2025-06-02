@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest

internal final class TwoFactorViewControllerTests: TestCase {
  func testView() {
    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.phone5_8inch, Device.pad]).forEach {
      language, device in
      withEnvironment(language: language) {
        let controller = Storyboard.Login.instantiate(TwoFactorViewController.self)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

        self.scheduler.run()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.99),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }
}
