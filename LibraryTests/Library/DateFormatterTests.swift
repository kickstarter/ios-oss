@testable import Library
import XCTest

final class DateFormatterTests: XCTestCase {
  func testMonthYear() {
    XCTAssertEqual("MMMMyyyy", DateFormatter.monthYear)
  }
}
