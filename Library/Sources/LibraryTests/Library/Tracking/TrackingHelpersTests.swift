@testable import Library
import XCTest

final class TrackingHelpersTests: TestCase {
  func testPledgeContext() {
    XCTAssertEqual(TrackingHelpers.pledgeContext(for: .pledge).trackingString, "new_pledge")
    XCTAssertEqual(TrackingHelpers.pledgeContext(for: .update).trackingString, "manage_pledge")
    XCTAssertEqual(TrackingHelpers.pledgeContext(for: .updateReward).trackingString, "manage_pledge")
    XCTAssertEqual(TrackingHelpers.pledgeContext(for: .changePaymentMethod).trackingString, "manage_pledge")
    XCTAssertEqual(TrackingHelpers.pledgeContext(for: .fixPaymentMethod).trackingString, "fix_errored_pledge")
  }
}
