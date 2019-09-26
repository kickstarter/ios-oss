@testable import KsApi
import Prelude
import XCTest

final class CreateBackingInputTests: XCTestCase {
  func testCreateBackingInputDictionary() {
    let createBackingInput = CreateBackingInput(
      amount: "200.00",
      locationId: "NY",
      paymentSourceId: "paymentSourceId",
      projectId: "projectId",
      rewardId: "rewardId",
      refParam: "activity"
    )

    let input = createBackingInput.toInputDictionary()

    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertEqual(input["locationId"] as? String, "NY")
    XCTAssertEqual(input["paymentSourceId"] as? String, "paymentSourceId")
    XCTAssertEqual(input["paymentType"] as? String, "credit_card")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["rewardId"] as? String, "rewardId")
    XCTAssertEqual(input["refParam"] as? String, "activity")
  }

  func testCreateBackingInputDictionary_TestNilLocationAndReward() {
    let createBackingInput = CreateBackingInput(
      amount: "200.00",
      locationId: nil,
      paymentSourceId: "paymentSourceId",
      projectId: "projectId",
      rewardId: nil,
      refParam: nil
    )

    let input = createBackingInput.toInputDictionary()

    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertNil(input["locationId"])
    XCTAssertEqual(input["paymentSourceId"] as? String, "paymentSourceId")
    XCTAssertEqual(input["paymentType"] as? String, "credit_card")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertNil(input["rewardId"])
    XCTAssertNil(input["refParam"])
  }
}
