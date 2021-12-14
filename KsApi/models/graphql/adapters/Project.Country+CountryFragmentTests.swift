import Foundation
@testable import KsApi
import XCTest

final class Country_CountryFragmentTests: XCTestCase {
  private let countryFragment = GraphAPI.CountryFragment(
    code: .us,
    name: "United States"
  )

  func testCurrency_WhenItsTheSameAsCountrysCurrency_Success() {
    let country = Project.Country.country(
      from: self.countryFragment,
      minPledge: 1,
      maxPledge: 8_500,
      currency: .usd
    )

    XCTAssertEqual(country?.countryCode, "US")
    XCTAssertEqual(country?.currencySymbol, "$")
    XCTAssertEqual(country?.maxPledge, 8_500)
    XCTAssertEqual(country?.minPledge, 1)
    XCTAssertEqual(country?.trailingCode, true)
  }

  func testCurrency_WhenItsNotTheSameAsCountrysCurrency_Success() {
    let country = Project.Country.country(
      from: self.countryFragment,
      minPledge: 1,
      maxPledge: 8_500,
      currency: .jpy
    )

    XCTAssertEqual(country?.countryCode, "US")
    XCTAssertEqual(country?.currencySymbol, "¥")
    XCTAssertEqual(country?.maxPledge, 8_500)
    XCTAssertEqual(country?.minPledge, 1)
    XCTAssertEqual(country?.trailingCode, true)
  }
}
