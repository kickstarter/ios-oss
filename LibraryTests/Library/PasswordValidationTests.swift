import Library
import XCTest

public final class PasswordValidationTests: XCTestCase {
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
    var text = passwordValidationText(true)
    XCTAssertEqual(text, nil)

    text = passwordValidationText(false)
    XCTAssertEqual(text, "Your password must be at least 6 characters long.")

    text = passwordValidationText((length: false, match: false))
    XCTAssertEqual(text, "Your password must be at least 6 characters long.")

    text = passwordValidationText((length: false, match: true))
    XCTAssertEqual(text, "Your password must be at least 6 characters long.")

    text = passwordValidationText((length: true, match: false))
    XCTAssertEqual(text, "New passwords must match.")

    text = passwordValidationText((length: true, match: true))
    XCTAssertEqual(text, nil)
  }
}
