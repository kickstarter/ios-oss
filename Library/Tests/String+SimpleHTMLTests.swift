import XCTest
@testable import Library

final class String_SimpleHTMLTests : XCTestCase {

  func testHtmlParsing() {

    let font = UIFont.systemFontOfSize(12.0)
    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"
    let stripped = "Hello Brandon, how are you?"

    guard let string = html.simpleHtmlAttributedString(font: font) else {
      XCTAssert(false, "Couldn't parse HTML string.")
      return
    }

    XCTAssertEqual(string.string, stripped)
  }

  func testHtmlWithAllFontsSpecified() {
    let font = UIFont.systemFontOfSize(12.0)
    let bold = UIFont.boldSystemFontOfSize(14.0)
    let italic = UIFont.italicSystemFontOfSize(16.0)

    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"

    guard let string = html.simpleHtmlAttributedString(font: font, bold: bold, italic: italic) else {
      XCTAssert(false, "Couldn't parse HTML string")
      return
    }

    let extractedBold = string.attribute(NSFontAttributeName, atIndex: 1, effectiveRange: nil) as? UIFont

    if let testBold = extractedBold {
      XCTAssertEqual(testBold.pointSize, bold.pointSize)
      XCTAssert(testBold.fontDescriptor().symbolicTraits.contains(.TraitBold))
    } else {
      XCTAssert(false, "Couldn't find font in attributed string")
    }

    let extractedItalic = string.attribute(NSFontAttributeName, atIndex: 7, effectiveRange: nil) as? UIFont
    if let testItalic = extractedItalic {
      XCTAssertEqual(testItalic.pointSize, italic.pointSize)
      XCTAssert(testItalic.fontDescriptor().symbolicTraits.contains(.TraitItalic))
    } else {
      XCTAssertEqual(false, "Couldn't find font in attributed string")
    }

    let extractedBase = string.attribute(NSFontAttributeName, atIndex: 16, effectiveRange: nil) as? UIFont
    if let testBase = extractedBase {
      XCTAssertEqual(testBase.pointSize, font.pointSize)
      XCTAssertFalse(testBase.fontDescriptor().symbolicTraits.contains(.TraitBold))
      XCTAssertFalse(testBase.fontDescriptor().symbolicTraits.contains(.TraitItalic))
    } else {
      XCTAssertEqual(false, "Couldn't find font in attributed string")
    }
  }

  func testHtmlWithFallbackFonts() {
    let font = UIFont.systemFontOfSize(12.0)

    let html = "<b>Hello</b> <i>Brandon</i>, how are you?"

    let string = html.simpleHtmlAttributedString(font: font)
    if string == nil {
      XCTAssert(false, "Couldn't parse HTML string")
    }

    let extractedBold = string?.attribute(NSFontAttributeName, atIndex: 1, effectiveRange: nil) as? UIFont
    if let testBold = extractedBold {
      XCTAssertEqual(testBold.pointSize, font.pointSize)
      XCTAssert(testBold.fontDescriptor().symbolicTraits.contains(.TraitBold))
    } else {
      XCTAssert(false, "Couldn't find font in attributed string")
    }

    let extractedItalic = string?.attribute(NSFontAttributeName, atIndex: 7, effectiveRange: nil) as? UIFont
    if let testItalic = extractedItalic {
      XCTAssertEqual(testItalic.pointSize, font.pointSize)
      XCTAssert(testItalic.fontDescriptor().symbolicTraits.contains(.TraitItalic))
    } else {
      XCTAssertEqual(false, "Couldn't find font in attributed string")
    }

    let extractedBase = string?.attribute(NSFontAttributeName, atIndex: 16, effectiveRange: nil) as? UIFont
    if let testBase = extractedBase {
      XCTAssertEqual(testBase.pointSize, font.pointSize)
      XCTAssertFalse(testBase.fontDescriptor().symbolicTraits.contains(.TraitBold))
      XCTAssertFalse(testBase.fontDescriptor().symbolicTraits.contains(.TraitItalic))
    } else {
      XCTAssertEqual(false, "Couldn't find font in attributed string")
    }
  }
}
