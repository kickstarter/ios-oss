import XCTest
@testable import Library

final class BorderButtonTests: XCTestCase {
  let button = BorderButton()

  func testDefaultStyle() {
    XCTAssertEqual("White", button.color)
    XCTAssertEqual("GrayDark", button.borderColor)
    XCTAssertEqual("Black", button.titleColorNormal)
    XCTAssertEqual("GrayLight", button.titleColorHighlighted)
    XCTAssertEqual("Body", button.titleFontStyle)
    XCTAssertEqual("Default", button.titleWeight)
  }

  func testValidStyles() {
    button.color = "Green"
    XCTAssertNotNil(button.color)
    XCTAssertEqual(Color.Green.toUIColor(), button.backgroundColor)

    button.borderColor = "Mint"
    XCTAssertNotNil(button.borderColor)
    XCTAssertEqual(button.layer.borderColor, Color.Mint.toUIColor().CGColor)

    button.titleColorNormal = "White"
    XCTAssertNotNil(button.titleColorNormal)
    XCTAssertEqual(Color.White.toUIColor(), button.titleColorForState(.Normal))

    button.titleColorHighlighted = "GrayDark"
    XCTAssertNotNil(button.titleColorHighlighted)
    XCTAssertEqual(Color.GrayDark.toUIColor(), button.titleColorForState(.Highlighted))

    button.titleFontStyle = "Headline"
    XCTAssertNotNil(button.titleFontStyle)
    XCTAssertEqual(FontStyle.Headline.toUIFont(), button.titleLabel?.font)

    button.titleWeight = "Medium"
    XCTAssertEqual("Medium", button.titleWeight)
  }

  func testInvalidStyles() {
    button.color = ""
    XCTAssertEqual(Color.mismatchedColor, button.backgroundColor)

    button.color = "Turnt"
    XCTAssertEqual(button.color, "")
    XCTAssertEqual(Color.mismatchedColor, button.backgroundColor)

    button.borderColor = "Blood"
    XCTAssertNotNil(button.borderColor)
    XCTAssertEqual(Color.mismatchedColor.CGColor, button.layer.borderColor)

    button.titleColorNormal = "Blu"
    XCTAssertNotNil(button.titleColorNormal)
    XCTAssertEqual(Color.mismatchedColor, button.titleColorForState(.Normal))

    button.titleColorHighlighted = "Pinky"
    XCTAssertNotNil(button.titleColorHighlighted)
    XCTAssertEqual(Color.mismatchedColor, button.titleColorForState(.Normal))

    button.titleWeight = "Med"
    XCTAssertEqual(button.titleWeight, "Default")
    XCTAssertEqual(FontStyle.Body.toUIFont(), button.titleLabel?.font)

    button.titleFontStyle = "Head"
    XCTAssertEqual(button.titleFontStyle, "")
    XCTAssertEqual(FontStyle.mismatchedFont, button.titleLabel?.font)
  }
}

