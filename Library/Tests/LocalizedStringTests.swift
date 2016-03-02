import XCTest
@testable import Library

class LocalizedStringTests : XCTestCase {

  func testLocalizingInGerman() {
    withEnvironment(language: .de, mainBundle: MockBundle()) {
      XCTAssertEqual("de_world", localizedString(key: "hello"))
      XCTAssertEqual("Hello", localizedString(key: "hello_", defaultValue: "Hello"))
      XCTAssertEqual("", localizedString(key: "hello_"))
      XCTAssertEqual("de_hello A B", localizedString(key: "hello_format", substitutions: ["a": "A", "b": "B"]))

      XCTAssertEqual("", localizedString(key: "echo"), "When key/value are equal we should "
        + "return an empty string")
    }
  }

  func testLocalizedStringWithCount() {
    withEnvironment(language: .en, mainBundle: MockBundle()) {
      XCTAssertEqual(localizedString(key: "test_count", count: 0), "zero")
      XCTAssertEqual(localizedString(key: "test_count", count: 1), "one")
      XCTAssertEqual(localizedString(key: "test_count", count: 2), "two")
      XCTAssertEqual(localizedString(key: "test_count", count: 3, substitutions: ["the_count": "3"]), "3 few")
      XCTAssertEqual(localizedString(key: "test_count", count: 4, substitutions: ["the_count": "4"]), "4 few")
      XCTAssertEqual(localizedString(key: "test_count", count: 5, substitutions: ["the_count": "5"]), "5 few")
      XCTAssertEqual(localizedString(key: "test_count", count: 6, substitutions: ["the_count": "6"]), "6 many")
    }
  }

  func testSimpleSubstitution() {
    let rawString = "Hello %{name}, it's %{temp} degrees out today."
    let subString = substitute(rawString, with: ["name": "Brandon", "temp": "100"])
    XCTAssertEqual(subString, "Hello Brandon, it's 100 degrees out today.")
  }

  func testNoSubstitutions() {
    let rawString = "Hello Brandon, it's 100 degrees out today."
    let subString = substitute(rawString, with: [:])
    XCTAssertEqual(subString, subString)
  }

  func testMissingSubtitution() {
    let rawString = "Hello %{name}, it's %{temp} degrees out today."
    let subString = substitute(rawString, with: ["name": "Brandon"])
    XCTAssertEqual(subString, "Hello Brandon, it's %{temp} degrees out today.")
  }

  func testTooManySubstitutions() {
    let rawString = "Hello %{name}, it's %{temp} degrees out today."
    let subString = substitute(rawString, with: ["name": "Brandon", "temp": "100", "extra": "XYZ"])
    XCTAssertEqual(subString, "Hello Brandon, it's 100 degrees out today.")
  }
}
