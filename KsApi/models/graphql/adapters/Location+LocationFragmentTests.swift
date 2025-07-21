import Foundation
import GraphAPI
@testable import KsApi
import XCTest

final class Location_LocationFragmentTests: XCTestCase {
  func test() {
    let locationFragment: GraphAPI.LocationFragment = try! testGraphObject(
      jsonString:
      """
        {
              "__typename": "Location",
              "country": "CA",
              "countryName": "Canada",
              "displayableName": "Canada",
              "id": "TG9jYXRpb24tMjM0MjQ3NzU=",
              "name": "Canada"
       }
      """
    )

    XCTAssertNotNil(Location.location(from: locationFragment))
  }
}
