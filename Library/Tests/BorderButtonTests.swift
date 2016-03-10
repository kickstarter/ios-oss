import XCTest
@testable import Library

final class BorderButtonTests: XCTestCase {
  let button = BorderButton()

  func testDefaultStyle() {
    XCTAssertEqual(button.color, "White")
    XCTAssertEqual(button.borderColor, "GrayDark")
    XCTAssertEqual(button.titleColorNormal, "Black")
    XCTAssertEqual(button.titleColorHighlighted, "GrayLight")
    XCTAssertEqual(button.titleFontText, "Body")
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

    button.titleFontText = "Headline"
    XCTAssertNotNil(button.titleFontText)
    XCTAssertEqual(button.titleLabel?.font, FontText.Headline.toUIFont())

    button.titleWeight = "Medium"
    XCTAssertEqual(button.titleWeight, "Medium")
  }

  func testInvalidStyles() {
    button.color = ""
    XCTAssertEqual(button.backgroundColor, UIColor.redColor())

    button.color = "Turnt"
    XCTAssertEqual(button.color, "")
    XCTAssertEqual(button.backgroundColor, UIColor.redColor())

    button.borderColor = "Blood"
    XCTAssertNotNil(button.borderColor)
    XCTAssertTrue(CGColorEqualToColor(button.layer.borderColor, UIColor.redColor().CGColor))

    button.titleColorNormal = "Blu"
    XCTAssertNotNil(button.titleColorNormal)
    XCTAssertEqual(button.titleColorForState(.Normal), UIColor.redColor())

    button.titleColorHighlighted = "Pinky"
    XCTAssertNotNil(button.titleColorHighlighted)
    XCTAssertEqual(button.titleColorForState(.Normal), UIColor.redColor())

    button.titleWeight = "Med"
    XCTAssertEqual(button.titleWeight, "Default")
    XCTAssertEqual(button.titleLabel?.font, FontText.Body.toUIFont())

    button.titleFontText = "Head"
    XCTAssertEqual(button.titleFontText, "")
    XCTAssertEqual(button.titleLabel?.font, UIFont(name: "Marker Felt", size: 15.0))
  }
}

