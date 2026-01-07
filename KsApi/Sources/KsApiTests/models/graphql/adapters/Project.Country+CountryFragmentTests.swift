import ApolloTestSupport
import Foundation
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class Country_CountryFragmentTests: XCTestCase {
  private var countryFragment: GraphAPI.CountryFragment {
    let mock = Mock<GraphAPITestMocks.Country>()
    mock.code = GraphQLEnum.case(GraphAPI.CountryCode.us)
    mock.name = "United States"

    return GraphAPI.CountryFragment.from(mock)
  }

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
