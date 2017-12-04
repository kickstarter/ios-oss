import XCTest
@testable import Library

class String_Base64Tests: XCTestCase {

  func testBase64FunctionReturnsCorrectString() {
    let string = "Category-1"
    let base64String = string.toBase64()
    XCTAssertEqual(base64String, "Q2F0ZWdvcnktMQ==")
  }
}
