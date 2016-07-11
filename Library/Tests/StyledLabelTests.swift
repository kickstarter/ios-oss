import XCTest
@testable import Library

final class StyledLabelTests: XCTestCase {

  func testDefaultStyle() {
    let label = StyledLabel()

    XCTAssertEqual("Body", label._fontStyle)
    XCTAssertEqual("TextDefault", label._color)
    XCTAssertEqual("Default", label._weight)
  }

  func test_IB_WithValidStyles() {
    let label = StyledLabel()

    label._fontStyle = "Headline"
    XCTAssertNotNil(label.fontStyle)
    XCTAssertEqual(UIFont.ksr_headline(), label.font)

    label._weight = "Medium"
    XCTAssertEqual("Medium", label.weight?.rawValue)
  }

  func test_IB_WithInvalidStyles() {
    let label = StyledLabel()

    label._color = "Blu"
    XCTAssertNil(label.color, "Incorrect color should clear the color enum.")
    XCTAssertEqual(Color.mismatchedColor, label.textColor,
      "Incorrect color should set label color to mismatched color.")

    label._weight = "Med"
    XCTAssertNil(label.weight, "Incorrect weight should clear the weight enum.")

    label._fontStyle = "Head"
    XCTAssertNil(label.fontStyle, "Incorrect font should clear the font style enum.")
    XCTAssertEqual(FontStyle.mismatchedFont, label.font,
      "Incorrect font should set label font to a mismatched font.")
  }
}
