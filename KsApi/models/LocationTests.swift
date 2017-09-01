import XCTest
@testable import KsApi
import Prelude

final class LocationTests: XCTestCase {

  func testEquatable() {
    XCTAssertEqual(Location.template, Location.template)
    XCTAssertNotEqual(Location.template, Location.template |> Location.lens.id %~ { $0 + 1 })
  }

  func testJSONParsing_WithPartialData() {

    let location = Location.decodeJSONDictionary([
      "id": 1
    ])

    XCTAssertNotNil(location.error)
  }

  func testJSONParsing_WithFullData() {

    let location = Location.decodeJSONDictionary([
      "country": "US",
      "id": 1,
      "localized_name": "Brooklyn, NY",
      "displayable_name": "Brooklyn, NY",
      "name": "Brooklyn"
    ])

    XCTAssertNil(location.error)
    XCTAssertEqual(location.value?.id, 1)
    XCTAssertEqual(location.value?.displayableName, "Brooklyn, NY")
    XCTAssertEqual(location.value?.name, "Brooklyn")
  }

  func testEncodeDecode() {
    let location: [String:Any] = [
      "country": "US",
      "id": 44,
      "localized_name": "New Amsterdam, NY",
      "displayable_name": "New Amsterdam, NY",
      "name": "New Amsterdam"
    ]

    let decodedLocation = Location.decodeJSONDictionary(location).value

    XCTAssertEqual(decodedLocation, Location.decodeJSONDictionary(decodedLocation?.encode() ?? [:]).value)
    XCTAssertEqual(decodedLocation?.encode() as NSDictionary?, location as NSDictionary?)
  }
}
