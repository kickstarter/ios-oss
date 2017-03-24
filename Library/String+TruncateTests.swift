import XCTest
@testable import Library

final class StringTruncateTests: XCTestCase {

  func testTruncates() {
    XCTAssertEqual("Hel…", "Hello".truncated(maxLength: 4))
    XCTAssertEqual("Hello", "Hello".truncated(maxLength: 5))
    XCTAssertEqual("Hello", "Hello".truncated(maxLength: 6))
    XCTAssertEqual("Hello…", "Hello world".truncated(maxLength: 6))
    XCTAssertEqual("Hello wo", "Hello world".truncated(maxLength: 8, suffix: ""))
    XCTAssertEqual("Hello !!", "Hello world".truncated(maxLength: 8, suffix: "!!"))
  }
}
