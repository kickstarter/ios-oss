@testable import Kickstarter_Framework
@testable import Library
import SnapshotTesting
import UIKit


final class ToggleViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView() {
    forEachScreenshotType(languages: [.en]) { type in
      withEnvironment(language: type.language) {
        let controller = ToggleViewController.instantiate()
        controller.titleLabel.text = "Title for testing purposes only"
        controller.toggle.setOn(true, animated: false)

        let width = type.device.deviceSize(in: type.orientation).width

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: CGSize(width: width, height: 60),
          perceptualPrecision: 0.98,
          testName: "testView"
        )
      }
    }
  }

  func testView_LargerText() {
    forEachScreenshotType(languages: [.en]) { type in
      withEnvironment(language: type.language) {
        let controller = ToggleViewController.instantiate()
        controller.titleLabel.text = "Title for testing purposes only"
        controller.toggle.setOn(true, animated: false)

        let width = type.device.deviceSize(in: type.orientation).width

        assertSnapshot(
          forView: controller.view,
          withType: type,
          size: CGSize(width: width, height: 300),
          perceptualPrecision: 0.98,
          testName: "testView_LargerText"
        )
      }
    }
  }
}
