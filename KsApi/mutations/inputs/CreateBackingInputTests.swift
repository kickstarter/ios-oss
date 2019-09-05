@testable import KsApi
import Prelude
import XCTest

final class CreateBackingInputTests: XCTestCase {
  func testCreateBackingInputDictionary() {
    let createBackingInput = CreateBackingInput(
      amount: "200.00",
      locationId: "NY",
      paymentSourceId: "paymentSourceId",
      paymentType: "card",
      projectId: "projectId",
      rewardId: "rewardId"
    )

    let input = createBackingInput.toInputDictionary()

    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertEqual(input["locationId"] as? String, "NY")
    XCTAssertEqual(input["paymentSourceId"] as? String, "paymentSourceId")
    XCTAssertEqual(input["paymentType"] as? String, "card")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["rewardId"] as? String, "rewardId")
  }
}
