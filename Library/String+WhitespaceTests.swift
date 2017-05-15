import XCTest
@testable import Library

final class StringWhitespaceTests: XCTestCase {

  func testNonBreakingSpaced() {
    XCTAssertEqual("Hello\u{00a0}world", "Hello world".nonBreakingSpaced())
    XCTAssertEqual("Howdy", "Howdy".nonBreakingSpaced())
  }

  func testTrimmed() {
    XCTAssertEqual("", " ".trimmed())
    XCTAssertEqual("", "\n".trimmed())
    XCTAssertEqual("", " \n ".trimmed())
    XCTAssertEqual("foo", " foo ".trimmed())
  }

  func testIsWhitespacesAndNewlines() {
    XCTAssertTrue(isWhitespacesAndNewlines(""))
    XCTAssertTrue(isWhitespacesAndNewlines(" "))
    XCTAssertTrue(isWhitespacesAndNewlines("\n"))
    XCTAssertFalse(isWhitespacesAndNewlines("  f  "))
  }
}
