import XCTest
import Library

final class HelpTypeTests: XCTestCase {
  func testAccessibilityTraits() {
    XCTAssertEqual(HelpType.helpCenter.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.contact.accessibilityTraits, UIAccessibilityTraits.button)
    XCTAssertEqual(HelpType.howItWorks.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.terms.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.privacy.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.cookie.accessibilityTraits, UIAccessibilityTraits.link)
    XCTAssertEqual(HelpType.trust.accessibilityTraits, UIAccessibilityTraits.link)
  }
}
