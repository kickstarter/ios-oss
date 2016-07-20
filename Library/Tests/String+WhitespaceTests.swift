import XCTest
@testable import Library

final class StringWhitespaceTests: XCTestCase {

  func testNonBreakingSpaced() {
    XCTAssertEqual("Hello\u{00a0}world", "Hello world".nonBreakingSpaced())
    XCTAssertEqual("Howdy", "Howdy".nonBreakingSpaced())
  }
}
