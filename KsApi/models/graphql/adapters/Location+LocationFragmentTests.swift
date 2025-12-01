import Foundation
import GraphAPI
@testable import KsApi
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

  func testSimpleShippingRule() {
    let simpleShippingRuleFragment = GraphAPI.SimpleShippingRuleLocationFragment(
      locationId: "TG9jYXRpb24tMjM0MjQ3NzU=",
      locationName: "Canada",
      country: "CA"
    )

    XCTAssertNotNil(Location.location(from: simpleShippingRuleFragment))
  }

  func testFlattenAndDedupeLocations() {
    let allRewardLocations: [[Location]] = [
      [Location.usa],
      [Location.usa, Location.australia],
      [Location.australia, Location.canada]
    ]

    let flattened = Location.flattenAndDedupeLocations(from: allRewardLocations)
    XCTAssertEqual(flattened, [Location.usa, Location.australia, Location.canada])
  }
}
