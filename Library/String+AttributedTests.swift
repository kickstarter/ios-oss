@testable import Library
import XCTest

final class String_AttributedTests: TestCase {
  func testCombining() {
    let s1 = NSAttributedString(string: "prefix")
    let s2 = NSAttributedString(string: "suffix")

    let combined = s1 + s2

    XCTAssertEqual("prefixsuffix", combined.string)
  }

  func testAttributedBolding() {
    let string = "My special string of words"

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let attributes = [
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    let font = UIFont.ksr_body()
    let boldedFont = UIFont.ksr_body().bolded
    let foregroundColor = UIColor.ksr_support_700

    let attributed = string.attributed(
      with: font,
      foregroundColor: foregroundColor,
      attributes: attributes,
      bolding: ["words"]
    )

    let allAttributes = attributed.attributes(
      at: 0,
      longestEffectiveRange: nil,
      in: (string as NSString).range(of: string)
    )

    XCTAssertEqual(allAttributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle, paragraphStyle)
    XCTAssertEqual(allAttributes[NSAttributedString.Key.font] as? UIFont, font)
    XCTAssertEqual(allAttributes[NSAttributedString.Key.foregroundColor] as? UIColor, foregroundColor)

    let boldedRange = (string as NSString).range(of: "words")

    let boldedAttributes = attributed.attributes(
      at: boldedRange.location,
      longestEffectiveRange: nil,
      in: boldedRange
    )

    XCTAssertEqual(boldedAttributes[NSAttributedString.Key.font] as? UIFont, boldedFont)
  }
}
