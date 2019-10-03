@testable import Library
import XCTest

final class NSMutableAttributedString_SetFontKeepingTraitsTests: XCTestCase {
  func test() {
    let string = "What a lovely string"
    let initialFont = UIFont.systemFont(ofSize: 12.0)
    let initialColor = UIColor.blue

    let replacementFont = UIFont.ksr_body()
    let replacementColor = UIColor.ksr_green_500

    let attributedString = NSMutableAttributedString(
      string: string,
      attributes: [
        .font: initialFont,
        .foregroundColor: initialColor
      ]
    )

    let range = NSRange(location: 0, length: attributedString.length)

    attributedString
      .enumerateAttribute(.font, in: range) { value, _, _ in
        XCTAssertEqual((value as? UIFont)?.fontName, initialFont.fontName)
        XCTAssertEqual((value as? UIFont)?.pointSize, initialFont.pointSize)
      }

    attributedString
      .enumerateAttribute(.foregroundColor, in: range) { value, _, _ in
        XCTAssertEqual(value as? UIColor, initialColor)
      }

    attributedString.setFontKeepingTraits(to: replacementFont, color: replacementColor)

    attributedString
      .enumerateAttribute(.font, in: range) { value, _, _ in
        XCTAssertEqual((value as? UIFont)?.fontName, replacementFont.fontName)
        XCTAssertEqual((value as? UIFont)?.pointSize, replacementFont.pointSize)
      }

    attributedString
      .enumerateAttribute(.foregroundColor, in: range) { value, _, _ in
        XCTAssertEqual(value as? UIColor, replacementColor)
      }
  }
}
