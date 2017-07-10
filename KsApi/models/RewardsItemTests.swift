import Prelude
import XCTest
@testable import KsApi

final class RewardsItemTests: XCTestCase {

  func testDecoding() {
    let decoded = RewardsItem.decodeJSONDictionary([
      "id": 1,
      "item": [
        "description": "Hello",
        "id": 1,
        "name": "The thing",
        "project_id": 1
      ],
      "quantity": 2,
      "reward_id": 3
    ])

    XCTAssertNil(decoded.error)

    XCTAssertEqual(1, decoded.value?.id)
    XCTAssertEqual(2, decoded.value?.quantity)
    XCTAssertEqual(3, decoded.value?.rewardId)

    XCTAssertEqual("Hello", decoded.value?.item.description)
    XCTAssertEqual(1, decoded.value?.item.id)
    XCTAssertEqual("The thing", decoded.value?.item.name)
    XCTAssertEqual(1, decoded.value?.item.projectId)
  }
}
