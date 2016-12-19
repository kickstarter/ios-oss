import XCTest
@testable import Library

final class EnvironmentTests: XCTestCase {

  func testInit() {
    let env = Environment()

    XCTAssertEqual(env.calendar, Calendar.currentCalendar())
    XCTAssertEqual(env.language, Language(languageStrings: Locale.preferredLanguages()))
    XCTAssertEqual(env.timeZone, TimeZone.localTimeZone())
    XCTAssertEqual(env.locale, Locale.currentLocale())
    XCTAssertEqual(env.countryCode, "US")
  }

  func testDescription() {
    XCTAssertNotEqual(Environment().description, "")
    XCTAssertNotEqual(Environment().debugDescription, "")
  }
}
