import XCTest
@testable import Kickstarter_tvOS

final class UILabelIBClearTests : XCTestCase {

  func testClearIBValue() {
    let label = UILabel()

    label.text = "howdy"
    label.clearIBValue = true
    XCTAssertEqual(label.text, "")

    label.text = "howdy"
    label.clearIBValue = false
    XCTAssertEqual(label.text, "howdy")
    XCTAssertEqual(label.clearIBValue, false)
  }
}
