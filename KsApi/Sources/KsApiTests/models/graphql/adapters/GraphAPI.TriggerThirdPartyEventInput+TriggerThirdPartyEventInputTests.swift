import GraphAPI
@testable import KsApi
import XCTest

class GraphAPI_TriggerThirdPartyEventInput_TriggerThirdPartyEventInputTests: XCTestCase {
  func testTriggerThirdEventPartyInputCreation_WithValidData_Success() {
    let input =
      TriggerThirdPartyEventInput(
        deviceId: "deviceId",
        eventName: "eventName",
        projectId: "projectId",
        pledgeAmount: 1.0,
        shipping: 2.0,
        transactionId: "transactionId",
        userId: "userId",
        appData: GraphAPI.AppDataInput(
          advertiserTrackingEnabled: true,
          applicationTrackingEnabled: true,
          extinfo: ["appData"]
        ),
        clientMutationId: ""
      )

    let graphInput = GraphAPI.TriggerThirdPartyEventInput.from(input)

    XCTAssertEqual(graphInput.deviceId, input.deviceId)
    XCTAssertEqual(graphInput.eventName, input.eventName)
    XCTAssertEqual(graphInput.projectId, input.projectId)
    XCTAssertEqual(graphInput.pledgeAmount.unwrapped, input.pledgeAmount)
    XCTAssertEqual(graphInput.shipping.unwrapped, input.shipping)
    XCTAssertEqual(graphInput.transactionId.unwrapped, input.transactionId)
    XCTAssertEqual(graphInput.userId.unwrapped, input.userId)
    XCTAssertNotNil(graphInput.appData)
    XCTAssertEqual(graphInput.clientMutationId.unwrapped, input.clientMutationId)
  }
}
