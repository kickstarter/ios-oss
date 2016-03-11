import XCTest
@testable import Library

final class StyledLabelTests: XCTestCase {
  let label = StyledLabel()

  func testDefaultStyle() {
    XCTAssertEqual(label.fontStyle, "Body")
    XCTAssertEqual(label.color, "TextDefault")
    XCTAssertEqual(label.weight, "Default")
  }

  func testValidStyles() {
    label.fontStyle = "Headline"
    XCTAssertNotNil(label.fontStyle)
    XCTAssertEqual(label.font, FontStyle.Headline.toUIFont())

    label.color = "Blue"
    XCTAssertNotNil(label.color)
    XCTAssertEqual(label.textColor, Color.Blue.toUIColor())

    label.weight = "Medium"
    XCTAssertEqual(label.weight, "Medium")
  }

  func testInvalidStyles() {
    label.color = "Blu"
    XCTAssertEqual(label.color, "")
    XCTAssertEqual(label.textColor, UIColor.redColor())

    label.weight = "Med"
    XCTAssertEqual(label.weight, "Default")
    XCTAssertEqual(label.font, FontStyle.Body.toUIFont())

    label.fontStyle = "Head"
    XCTAssertEqual(label.fontStyle, "")
    XCTAssertEqual(label.font, FontStyle.mismatchedFont)
  }
}
