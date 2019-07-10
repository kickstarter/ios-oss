@testable import Library
import XCTest

class LocalizedStringTests: XCTestCase {
  fileprivate let mockBundle = MockBundle()

  func testLocalizedPostalCode_USA() {
    withEnvironment(locale: Locale(identifier: "de_US")) {
      XCTAssertEqual("Zip code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "en_US")) {
      XCTAssertEqual("Zip code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "es_US")) {
      XCTAssertEqual("Zip code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "fr_US")) {
      XCTAssertEqual("Zip code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "ja_US")) {
      XCTAssertEqual("Zip code", localizedPostalCode())
    }
  }

  func testLocalizedPostalCode_Canada() {
    withEnvironment(locale: Locale(identifier: "de_CA")) {
      XCTAssertEqual("Postal code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "en_CA")) {
      XCTAssertEqual("Postal code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "es_CA")) {
      XCTAssertEqual("Postal code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "fr_CA")) {
      XCTAssertEqual("Postal code", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "ja_CA")) {
      XCTAssertEqual("Postal code", localizedPostalCode())
    }
  }

  func testLocalizedPostalCode_Other() {
    withEnvironment(locale: Locale(identifier: "de_AU")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "en_GB")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "es_FR")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "fr_AT")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "ja_CH")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }
  }

  func testLocalizedPostalCode_No_Region() {
    withEnvironment(locale: Locale(identifier: "de")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "en")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "es")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "fr")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }

    withEnvironment(locale: Locale(identifier: "ja")) {
      XCTAssertEqual("Postcode", localizedPostalCode())
    }
  }

  func testLocalizingInGerman() {
    withEnvironment(language: .de) {
      XCTAssertEqual("de_world", localizedString(key: "hello", bundle: mockBundle))
      XCTAssertEqual("Hello", localizedString(key: "hello_", defaultValue: "Hello", bundle: mockBundle))
      XCTAssertEqual("", localizedString(key: "hello_", bundle: mockBundle))

      XCTAssertEqual(
        "de_hello A B",
        localizedString(key: "hello_format", substitutions: ["a": "A", "b": "B"], bundle: mockBundle)
      )

      XCTAssertEqual(
        "",
        localizedString(key: "echo", bundle: mockBundle),
        "When key/value are equal we should return an empty string"
      )
    }
  }

  func testLocalizedStringWithCount() {
    withEnvironment(language: .en, mainBundle: MockBundle()) {
      XCTAssertEqual(localizedString(key: "test_count", count: 0, bundle: mockBundle), "zero")

      XCTAssertEqual(localizedString(key: "test_count", count: 1, bundle: mockBundle), "one")

      XCTAssertEqual(localizedString(key: "test_count", count: 2, bundle: mockBundle), "two")

      XCTAssertEqual(
        localizedString(key: "test_count", count: 3, substitutions: ["the_count": "3"], bundle: mockBundle),
        "3 few"
      )

      XCTAssertEqual(
        localizedString(key: "test_count", count: 4, substitutions: ["the_count": "4"], bundle: mockBundle),
        "4 few"
      )

      XCTAssertEqual(
        localizedString(key: "test_count", count: 5, substitutions: ["the_count": "5"], bundle: mockBundle),
        "5 few"
      )

      XCTAssertEqual(
        localizedString(key: "test_count", count: 6, substitutions: ["the_count": "6"], bundle: mockBundle),
        "6 many"
      )
    }
  }

  func testMissingKeyWithCount() {
    withEnvironment(language: .en, mainBundle: MockBundle()) {
      XCTAssertEqual(
        "10 backers",
        localizedString(
          key: "missing.key",
          defaultValue: "%{count} backers",
          count: 10,
          substitutions: ["count": "10"],
          bundle: mockBundle
        )
      )
    }
  }
}
