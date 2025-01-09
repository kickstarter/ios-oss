@testable import KsApi
import XCTest

class TimeInterval_ISO8601DateTests: XCTestCase {
  func testToISO8601DateTimeString() {
    let timeInterval = 1_506_897_315.0

    XCTAssertEqual(timeInterval.toISO8601DateTimeString(), "2017-10-01T22:35:15Z")
  }

  func testToISO8601DateTimeString_Future() {
    let timeInterval = 1_680_078_655.0

    XCTAssertEqual(timeInterval.toISO8601DateTimeString(), "2023-03-29T08:30:55Z")
  }

  func testFromISO8601DateTimeString() {
    XCTAssertEqual(TimeInterval.from(ISO8601DateTimeString: "2017-10-01T22:35:15Z"), 1_506_897_315.0)
    XCTAssertEqual(TimeInterval.from(ISO8601DateTimeString: "2023-03-29T08:30:55Z"), 1_680_078_655.0)
    XCTAssertEqual(TimeInterval.from(ISO8601DateTimeString: "2025-03-31T10:29:19-04:00"), 1_743_431_359.0)
  }
}
