@testable import Kickstarter_Framework
import Library
@testable import LibraryTestHelpers
import SnapshotTesting
import XCTest

internal final class LoginToutViewControllerTests: TestCase {
  func testLoginToutView() {
    let intents = [LoginIntent.generic, .starProject, .messageCreator, .backProject]

    forEachScreenshotType(withData: intents) { type, intent in
      let controller = LoginToutViewController.configuredWith(loginIntent: intent)
      assertSnapshot(forController: controller, withType: type)
    }
  }

  func testScrollToTop() {
    let intent = LoginIntent.generic
    let controller = LoginToutViewController.configuredWith(loginIntent: intent)

    // Due to the new design, a background imageView is now added as subview before the scroll.
    XCTAssertNotNil(controller.view.subviews[1] as? UIScrollView)
  }
}
