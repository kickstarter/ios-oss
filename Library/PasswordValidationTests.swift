import XCTest
import Library

public final class PasswordValidationTests: XCTestCase {
  func testPasswordsMatch() {
    XCTAssertFalse(passwordsMatch((first: "ArayStark123", second: "JonSnow456")))
    XCTAssertTrue(passwordsMatch((first: "Winter1sComing", second: "Winter1sComing")))
  }

  func testPasswordLenghtValid() {
    XCTAssertFalse(passwordLengthValid("C"))
    XCTAssertFalse(passwordLengthValid("Ce"))
    XCTAssertFalse(passwordLengthValid("Ce"))
    XCTAssertFalse(passwordLengthValid("Cer"))
    XCTAssertFalse(passwordLengthValid("Cers"))
    XCTAssertFalse(passwordLengthValid("Cerse"))
    XCTAssertTrue(passwordLengthValid("Cersei"))
    XCTAssertTrue(passwordLengthValid("Cersei0"))
  }

  func testPasswordFormValidation() {
    XCTAssertFalse(passwordFormValid((notEmpty: false, match: false, length: false)))
    XCTAssertFalse(passwordFormValid((notEmpty: false, match: false, length: true)))
    XCTAssertFalse(passwordFormValid((notEmpty: false, match: true, length: false)))
    XCTAssertFalse(passwordFormValid((notEmpty: true, match: false, length: false)))
    XCTAssertFalse(passwordFormValid((notEmpty: false, match: true, length: true)))
    XCTAssertFalse(passwordFormValid((notEmpty: true, match: true, length: false)))
    XCTAssertFalse(passwordFormValid((notEmpty: true, match: false, length: true)))
    XCTAssertTrue(passwordFormValid((notEmpty: true, match: true, length: true)))
  }

  func testPasswordValidationText() {
    var text = passwordValidationText((match: false, length: false))
    XCTAssertEqual(text, "Your password must be at least 6 characters long.")

    text = passwordValidationText((match: true, length: false))
    XCTAssertEqual(text, "Your password must be at least 6 characters long.")

    text = passwordValidationText((match: false, length: true))
    XCTAssertEqual(text, "New passwords must match.")

    text = passwordValidationText((match: true, length: true))
    XCTAssertEqual(text, nil)
  }
}
