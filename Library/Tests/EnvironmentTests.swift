import XCTest
@testable import Library

final class EnvironmentTests: XCTestCase {

  func testInit() {
    let env = Environment()

    XCTAssertEqual(env.calendar, NSCalendar.currentCalendar())
    XCTAssertEqual(env.language, Language(languageStrings: NSLocale.preferredLanguages()))
    XCTAssertEqual(env.timeZone, NSTimeZone.localTimeZone())
    XCTAssertEqual(env.locale, NSLocale.currentLocale())
    XCTAssertEqual(env.countryCode, "US")
  }

  func testDescription() {
    XCTAssertNotEqual(Environment().description, "")
    XCTAssertNotEqual(Environment().debugDescription, "")
  }
}
