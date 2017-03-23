import XCTest
import Library

final class IsValidEmailTests: XCTestCase {
  func testIsValidEmail() {
    XCTAssertFalse(isValidEmail("brando.n@kickstarter."))
    XCTAssertFalse(isValidEmail("brando.n@kickstarter"))
    XCTAssertFalse(isValidEmail("brando@kickstarter"))
    XCTAssertFalse(isValidEmail("@kickstarter.com"))
    XCTAssertFalse(isValidEmail("@."))
    XCTAssertTrue(isValidEmail("brando@kickstarter.com"))
    XCTAssertTrue(isValidEmail("BRANDO@kickstarter.com"))
    XCTAssertTrue(isValidEmail("brando+loves+mutation@gmail.com"))
    XCTAssertTrue(isValidEmail("a@b.c"))
    XCTAssertTrue(isValidEmail("brando@kick.start.er"))
  }
}
