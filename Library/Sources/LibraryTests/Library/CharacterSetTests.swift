@testable import Library
import XCTest

final class CharacterSetTests: TestCase {
  func testDecimalSeparators() {
    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertTrue(CharacterSet.ksr_decimalSeparators().contains("."))
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertTrue(CharacterSet.ksr_decimalSeparators().contains(","))
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertTrue(CharacterSet.ksr_decimalSeparators().contains(","))
    }

    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertTrue(CharacterSet.ksr_decimalSeparators().contains(","))
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      XCTAssertTrue(CharacterSet.ksr_decimalSeparators().contains("."))
    }
  }

  func testNumericCharacters() {
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("0"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("1"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("2"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("3"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("4"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("5"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("6"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("7"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("8"))
    XCTAssertTrue(CharacterSet.ksr_numericCharacters().contains("9"))
  }
}
