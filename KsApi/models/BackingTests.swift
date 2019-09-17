@testable import KsApi
import XCTest

final class BackingTests: XCTestCase {
  func testJSONDecoding_WithCompleteData() {
    let backing = Backing.decodeJSONDictionary([
      "amount": 1.0,
      "backer_id": 1,
      "id": 1,
      "location_id": 1,
      "location_name": "United States",
      "pledged_at": 1_000,
      "project_country": "US",
      "project_id": 1,
      "sequence": 1,
      "status": "pledged"
    ])

    XCTAssertNil(backing.error)
    XCTAssertEqual(1.0, backing.value?.amount)
    XCTAssertEqual(1, backing.value?.backerId)
    XCTAssertEqual(1, backing.value?.id)
    XCTAssertEqual(1, backing.value?.locationId)
    XCTAssertEqual("United States", backing.value?.locationName)
    XCTAssertEqual(1_000, backing.value?.pledgedAt)
    XCTAssertEqual("US", backing.value?.projectCountry)
    XCTAssertEqual(1, backing.value?.projectId)
    XCTAssertEqual(1, backing.value?.sequence)
    XCTAssertEqual(Backing.Status.pledged, backing.value?.status)
  }
}
