import XCTest
@testable import Library

final class EquatableHelpersTests: TestCase {

  func testIsAnyOf() {
    XCTAssertTrue("one".isAny(of: "one", "two", "three"))
    XCTAssertFalse("five".isAny(of: "one", "two", "three"))
  }
}
