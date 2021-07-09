import Foundation
@testable import KsApi
import XCTest

final class Country_CountryFragmentTests: XCTestCase {
  func test() {
    let countryFragment = GraphAPI.CountryFragment(
      code: .us,
      name: "United States"
    )

    let country = Project.Country.country(from: countryFragment)

    XCTAssertEqual(country, .us)
  }
}
