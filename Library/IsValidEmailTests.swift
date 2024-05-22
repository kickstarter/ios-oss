import Library
import XCTest

final class IsValidEmailTests: XCTestCase {
  func testIsValidEmail() {
    XCTAssertFalse(isValidEmail("use.r@example."))
    XCTAssertFalse(isValidEmail("use.r@example"))
    XCTAssertFalse(isValidEmail("user@example"))
    XCTAssertFalse(isValidEmail("@example.com"))
    XCTAssertFalse(isValidEmail("@."))
    XCTAssertTrue(isValidEmail("user@example.com"))
    XCTAssertTrue(isValidEmail("USER@example.com"))
    XCTAssertTrue(isValidEmail("example+with+pluses@gmail.com"))
    XCTAssertTrue(isValidEmail("a@b.c"))
    XCTAssertTrue(isValidEmail("example@kick.start.er"))
  }
}
