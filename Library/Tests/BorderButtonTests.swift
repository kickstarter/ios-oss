import XCTest
@testable import Library

final class BorderButtonTests: XCTestCase {

  func testDefaultStyle() {
    let button = BorderButton()

    XCTAssertEqual("White", button._color)
    XCTAssertEqual("Black", button._borderColor)
    XCTAssertEqual("TextDefault", button._titleColorNormal)
    XCTAssertEqual("TextLightGray", button._titleColorHighlighted)
    XCTAssertEqual("Body", button._titleFontStyle)
    XCTAssertEqual("Default", button._titleWeight)
  }

  func testValidStyles() {
    let button = BorderButton()

    button._color = "Green"
    XCTAssertEqual(Color.Green.toUIColor(), button.backgroundColor)

    button._borderColor = "Mint"
    XCTAssertEqual(Color.Mint.toUIColor().CGColor, button.layer.borderColor)

    button._titleColorNormal = "White"
    XCTAssertEqual(Color.White.toUIColor(), button.titleColorForState(.Normal))

    button._titleColorHighlighted = "GrayDark"
    XCTAssertEqual(Color.GrayDark.toUIColor(), button.titleColorForState(.Highlighted))

    button._titleFontStyle = "Headline"
    XCTAssertEqual(FontStyle.Headline.toUIFont(), button.titleLabel?.font)

    button._titleWeight = "Medium"
    XCTAssertEqual("Medium", button.titleWeight?.rawValue)
  }

  func testInvalidStyles() {
    let button = BorderButton()

    button._color = ""
    XCTAssertEqual(Color.mismatchedColor, button.backgroundColor)

    button._color = "Turnt"
    XCTAssertNil(button.color?.rawValue)
    XCTAssertEqual(Color.mismatchedColor, button.backgroundColor)

    button._borderColor = "Blood"
    XCTAssertEqual(Color.mismatchedColor.CGColor, button.layer.borderColor)

    button._titleColorNormal = "Blu"
    XCTAssertNil(button.titleColorNormal)
    XCTAssertEqual(Color.mismatchedColor, button.titleColorForState(.Normal))

    button._titleColorHighlighted = "Pinky"
    XCTAssertNil(button.titleColorHighlighted)
    XCTAssertEqual(Color.mismatchedColor, button.titleColorForState(.Normal))

    button._titleWeight = "Med"
    XCTAssertNil(button.titleWeight?.rawValue)

    button._titleFontStyle = "Head"
    XCTAssertNil(button.titleFontStyle?.rawValue)
    XCTAssertEqual(FontStyle.mismatchedFont, button.titleLabel?.font)
  }
}
