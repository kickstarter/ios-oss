@testable import KsApi
import XCTest

class GraphAPI_CreateFlaggingInput_CreateFlaggingInputTests: XCTestCase {
  func testCreateFlaggingInputCreation_WithValidData_Success() {
    let input = CreateCheckoutInput(
      projectId: "projectId",
      amount: "200.00",
      locationId: "NY",
      rewardIds: ["rewardId"],
      refParam: "project",
      clientMutationId: "clientMutationId"
    )

    let graphInput = GraphAPI.CreateCheckoutInput.from(input)

    XCTAssertEqual(graphInput.projectId, input.projectId)
    XCTAssertEqual(graphInput.amount, input.amount)
    XCTAssertEqual(graphInput.locationId, input.locationId)
    XCTAssertEqual(graphInput.rewardIds, input.rewardIds)
    XCTAssertEqual(graphInput.refParam, input.refParam)
    XCTAssertEqual(graphInput.clientMutationId, input.clientMutationId)
  }
}
