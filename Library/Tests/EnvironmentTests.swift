import XCTest
@testable import Library

final class EnvironmentTests: XCTestCase {

  func testInit() {
    let env = Environment()

    XCTAssertEqual(env.calendar, Calendar.current)
    XCTAssertEqual(env.language, Language(languageStrings: Locale.preferredLanguages))
    XCTAssertEqual(env.timeZone, TimeZone.current)
    XCTAssertEqual(env.locale, Locale.current)
    XCTAssertEqual(env.countryCode, "US")
  }
}
