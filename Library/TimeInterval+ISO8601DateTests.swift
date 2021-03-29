@testable import Library
import XCTest

class TimeInterval_ISO8601DateTests: XCTestCase {
  func testConvertToISO8601DateTimeString_FromTimeInterval() {
    let timeInterval = 1_506_897_315.0

    let iSO8601DateTimeString = timeInterval.toISO8601DateTimeString()
    XCTAssertEqual(iSO8601DateTimeString, "2017-10-01T22:35:15Z")
  }
}
