@testable import Kickstarter_Framework
@testable import KsApi
import Library
import Prelude
import SnapshotTesting
import XCTest


internal final class TwoFactorViewControllerTests: TestCase {
  func testView() {
    forEachScreenshotType { type in
      withEnvironment(language: type.language) {
        let controller = Storyboard.Login.instantiate(TwoFactorViewController.self)

        self.scheduler.run()

        assertSnapshot(
          forController: controller,
          withType: type,
          perceptualPrecision: 0.99,
          testName: "testView"
        )
      }
    }
  }
}
