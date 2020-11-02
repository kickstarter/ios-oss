@testable import KsApi
import Prelude
import XCTest

final class RewardsItemTests: XCTestCase {
  func testDecoding() {
    let decoded: RewardsItem = try! RewardsItem.decodeJSONDictionary([
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

    XCTAssertEqual(1, decoded.id)
    XCTAssertEqual(2, decoded.quantity)
    XCTAssertEqual(3, decoded.rewardId)

    XCTAssertEqual("Hello", decoded.item.description)
    XCTAssertEqual(1, decoded.item.id)
    XCTAssertEqual("The thing", decoded.item.name)
    XCTAssertEqual(1, decoded.item.projectId)
  }
}
