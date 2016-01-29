import XCTest
@testable import kickstartertv

final class EnvironmentTests : XCTestCase {

  func testInit() {
    let env = Environment()

    XCTAssertEqual(env.language, Language.en)
    XCTAssertEqual(env.timeZone, NSTimeZone.localTimeZone())
    XCTAssertEqual(env.locale, NSLocale.currentLocale())
    XCTAssertEqual(env.countryCode, "US")
  }

  func testDescription() {
    XCTAssertNotEqual(Environment().description, "")
    XCTAssertNotEqual(Environment().debugDescription, "")
  }
}
