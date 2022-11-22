@testable import KsApi
@testable import Library
import XCTest

final class LaunchedCountriesTests: XCTestCase {
  func testCurrencyNeedsCode() {
    let launchedCountries = LaunchedCountries()

    XCTAssertTrue(launchedCountries.currencyNeedsCode("$"))
    XCTAssertTrue(launchedCountries.currencyNeedsCode("kr"))

    XCTAssertFalse(launchedCountries.currencyNeedsCode("£"))
    XCTAssertFalse(launchedCountries.currencyNeedsCode("€"))
    XCTAssertFalse(launchedCountries.currencyNeedsCode("zł"))

    XCTAssertFalse(launchedCountries.currencyNeedsCode("XYZ"))
  }

  func testAllCountriesSupported() {
    XCTAssertEqual(LaunchedCountries().countries, Project.Country.all)
  }

  func testLaunchedCountriesCreated() {
    let launchedCountries = LaunchedCountries(countries: [.us, .de])

    XCTAssertEqual(launchedCountries.countries, [.us, .de])
  }
}
