import XCTest
@testable import Library

final class StyledLabelTests: XCTestCase {
  let label = StyledLabel()

  func testDefaultStyle() {
    XCTAssertEqual(label.fontText, "Body")
    XCTAssertEqual(label.color, "TextDefault")
    XCTAssertEqual(label.weight, "Default")
  }

  func testValidStyles() {
    label.fontText = "Headline"
    XCTAssertNotNil(label.fontText)
    XCTAssertEqual(label.font, FontText.Headline.toUIFont())

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
    XCTAssertEqual(label.font, FontText.Body.toUIFont())

    label.fontText = "Head"
    XCTAssertEqual(label.fontText, "")
    XCTAssertEqual(label.font, UIFont(name: "Marker Felt", size: 15.0))
  }
}
