import XCTest
@testable import Kickstarter_tvOS

final class LaunchedCountriesTests : XCTestCase {

  func testCurrencyNeedsCode() {
    let launchedCountries = LaunchedCountries()

    XCTAssertTrue(launchedCountries.currencyNeedsCode("$"))
    XCTAssertTrue(launchedCountries.currencyNeedsCode("kr"))

    XCTAssertFalse(launchedCountries.currencyNeedsCode("£"))
    XCTAssertFalse(launchedCountries.currencyNeedsCode("€"))

    XCTAssertFalse(launchedCountries.currencyNeedsCode("XYZ"))
  }
}
