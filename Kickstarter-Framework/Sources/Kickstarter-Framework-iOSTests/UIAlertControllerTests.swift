// @testable import Kickstarter_Framework
@testable import Library
@testable import LibraryTestHelpers
import UIKit
import XCTest

final class UIAlertControllerTests: TestCase {
  func testRequiresPopOverConfiguration_iPad_isTrue() {
    let device = MockDevice.init(userInterfaceIdiom: .pad)
    withEnvironment(device: device) {
      XCTAssertTrue(UIAlertController.requiresPopOverConfiguration(.actionSheet))
    }
  }

  func testRequiresPopOverConfiguration_iPhone_isFalse() {
    let device = MockDevice.init(userInterfaceIdiom: .phone)
    withEnvironment(device: device) {
      XCTAssertFalse(UIAlertController.requiresPopOverConfiguration(.actionSheet))
    }
  }
}
