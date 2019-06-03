@testable import KsApi
import XCTest

final class BackingTests: XCTestCase {
  func testJSONDecoding_WithCompleteData() {
    let backing = Backing.decodeJSONDictionary([
      "amount": 1.0,
      "backer_id": 1,
      "id": 1,
      "location_id": 1,
      "pledged_at": 1_000,
      "project_country": "US",
      "project_id": 1,
      "sequence": 1,
      "status": "pledged"
    ])

    XCTAssertNil(backing.error)
    XCTAssertEqual(1, backing.value?.id)
    XCTAssertEqual(Backing.Status.pledged, backing.value?.status)
  }
}
