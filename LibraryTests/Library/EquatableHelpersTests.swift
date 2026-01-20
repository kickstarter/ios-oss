@testable import Library
@testable import LibraryTestHelpers
import XCTest

final class EquatableHelpersTests: TestCase {
  func testIsAnyOf() {
    XCTAssertTrue("one".isAny(of: "one", "two", "three"))
    XCTAssertFalse("five".isAny(of: "one", "two", "three"))
  }
}
