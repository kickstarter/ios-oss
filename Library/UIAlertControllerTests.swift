import XCTest
import UIKit
@testable import Kickstarter_Framework
@testable import Library

final class UIAlertControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment()
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.popEnvironment()
  }

  func testInit_iPad() {
    let device = MockDevice.init(userInterfaceIdiom: .pad)
    withEnvironment(device: device) {
      let sourceView = UIView()
      let controller = UIAlertController.init(title: "Title",
                                              message: "Message",
                                              preferredStyle: .actionSheet,
                                              sourceView: sourceView)

      XCTAssertEqual(controller.title, "Title")
      XCTAssertEqual(controller.message, "Message")
      XCTAssertEqual(controller.preferredStyle, .actionSheet)
      XCTAssertEqual(controller.modalPresentationStyle, .popover,
                     "iPad should always present actionSheet as popover")
      XCTAssertEqual(controller.popoverPresentationController?.sourceView, sourceView)
    }
  }

  func testInit_iPhone() {
    let device = MockDevice.init(userInterfaceIdiom: .phone)
    withEnvironment(device: device) {
      let controller = UIAlertController.init(title: "Title",
                                              message: "Message",
                                              preferredStyle: .actionSheet)

      XCTAssertEqual(controller.title, "Title")
      XCTAssertEqual(controller.message, "Message")
      XCTAssertEqual(controller.preferredStyle, .actionSheet)
    }
  }
}
