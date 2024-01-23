@testable import KsApi
import Prelude
import XCTest

final class CreateCheckoutInputTests: XCTestCase {
  func testCreateCheckoutInputDictionary() {
    let createCheckoutInput = CreateCheckoutInput(
      projectId: "projectId",
      amount: "200.00",
      locationId: "NY",
      rewardIds: ["rewardId"],
      refParam: "project",
      clientMutationId: "clientMutationId"
    )

    let input = createCheckoutInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["amount"] as? String, "200.00")
    XCTAssertEqual(input["locationId"] as? String, "NY")
    XCTAssertEqual(input["rewardIds"] as? [String], ["rewardId"])
    XCTAssertEqual(input["refParam"] as? String, "project")
    XCTAssertEqual(input["clientMutationId"] as? String, "clientMutationId")
  }
}
