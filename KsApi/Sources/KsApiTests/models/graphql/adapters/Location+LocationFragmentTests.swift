import Foundation
import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

final class Location_LocationFragmentTests: XCTestCase {
  func testLocationFragment() {
    let locationFragment = GraphAPI.LocationFragment(
      country: "CA",
      countryName: "Canada",
      displayableName: "Canada",
      id: "TG9jYXRpb24tMjM0MjQ3NzU=",
      name: "Canada"
    )

    XCTAssertNotNil(Location.location(from: locationFragment))
  }
}
