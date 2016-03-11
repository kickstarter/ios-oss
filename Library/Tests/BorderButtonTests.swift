import XCTest
@testable import Library

final class BorderButtonTests: XCTestCase {
  let button = BorderButton()

  func testDefaultStyle() {
    XCTAssertEqual(button.color, "White")
    XCTAssertEqual(button.borderColor, "GrayDark")
    XCTAssertEqual(button.titleColorNormal, "Black")
    XCTAssertEqual(button.titleColorHighlighted, "GrayLight")
    XCTAssertEqual(button.titleFontStyle, "Body")
    XCTAssertEqual(button.titleWeight, "Default")
  }

  func testValidStyles() {
    button.color = "Green"
    XCTAssertNotNil(button.color)
    XCTAssertEqual(button.backgroundColor, Color.Green.toUIColor())

    button.borderColor = "Mint"
    XCTAssertNotNil(button.borderColor)
    XCTAssertTrue(CGColorEqualToColor(button.layer.borderColor, Color.Mint.toUIColor().CGColor))

    button.titleColorNormal = "White"
    XCTAssertNotNil(button.titleColorNormal)
    XCTAssertEqual(button.titleColorForState(.Normal), Color.White.toUIColor())

    button.titleColorHighlighted = "GrayDark"
    XCTAssertNotNil(button.titleColorHighlighted)
    XCTAssertEqual(button.titleColorForState(.Highlighted), Color.GrayDark.toUIColor())

    button.titleFontStyle = "Headline"
    XCTAssertNotNil(button.titleFontStyle)
    XCTAssertEqual(button.titleLabel?.font, FontStyle.Headline.toUIFont())

    button.titleWeight = "Medium"
    XCTAssertEqual(button.titleWeight, "Medium")
  }

  func testInvalidStyles() {
    button.color = ""
    XCTAssertEqual(button.backgroundColor, Color.mismatchedColor)

    button.color = "Turnt"
    XCTAssertEqual(button.color, "")
    XCTAssertEqual(button.backgroundColor, Color.mismatchedColor)

    button.borderColor = "Blood"
    XCTAssertNotNil(button.borderColor)
    XCTAssertTrue(CGColorEqualToColor(button.layer.borderColor, Color.mismatchedColor.CGColor))

    button.titleColorNormal = "Blu"
    XCTAssertNotNil(button.titleColorNormal)
    XCTAssertEqual(button.titleColorForState(.Normal), Color.mismatchedColor)

    button.titleColorHighlighted = "Pinky"
    XCTAssertNotNil(button.titleColorHighlighted)
    XCTAssertEqual(button.titleColorForState(.Normal), Color.mismatchedColor)

    button.titleWeight = "Med"
    XCTAssertEqual(button.titleWeight, "Default")
    XCTAssertEqual(button.titleLabel?.font, FontStyle.Body.toUIFont())

    button.titleFontStyle = "Head"
    XCTAssertEqual(button.titleFontStyle, "")
    XCTAssertEqual(button.titleLabel?.font, FontStyle.mismatchedFont)
  }
}

