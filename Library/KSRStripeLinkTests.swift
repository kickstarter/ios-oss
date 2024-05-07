@testable import Library
import XCTest

final class KSRStripeLinkTests: XCTestCase {
  func testFormatLinkLabel() {
    XCTAssertEqual(KSRStripeLink.formatLinkLabel("Visa 1234"), "•••• 1234")
    XCTAssertEqual(KSRStripeLink.formatLinkLabel("1234 Visa"), "•••• 1234")
    XCTAssertEqual(KSRStripeLink.formatLinkLabel("Foobar"), nil)
  }
}
