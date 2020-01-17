@testable import Library
import XCTest

final class NSAttributedString_LinkTests: TestCase {
  func testAttributedLink() {
    let string = "My special string with "
    let linkString = "link"

    let fullString = string + linkString

    let attributed = NSAttributedString(string: fullString)
      .setAsLink(textToFind: linkString, linkURL: "https://ksr.com")

    let linkRange = (fullString as NSString).range(of: linkString)

    let linkAttributes = attributed.attributes(
      at: linkRange.location,
      longestEffectiveRange: nil,
      in: linkRange
    )

    XCTAssertEqual(linkAttributes[NSAttributedString.Key.link] as? String, "https://ksr.com")
  }
}
