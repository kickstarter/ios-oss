@testable import KsApi
import XCTest

final class TriggerThirdPartyEventInputTests: XCTestCase {
  func testTriggerThirdPartyEventInputTestsDictionary_WithValue_Success() {
    let triggerThirdPartyEventInput =
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

    let input = triggerThirdPartyEventInput.toInputDictionary()

    XCTAssertEqual(input["deviceId"] as? String, "deviceId")
    XCTAssertEqual(input["eventName"] as? String, "eventName")
    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["pledgeAmount"] as? Double, 1.0)
    XCTAssertEqual(input["shipping"] as? Double, 2.0)
    XCTAssertEqual(input["transactionId"] as? String, "transactionId")
    XCTAssertEqual(input["userId"] as? String, "userId")
    XCTAssertNotNil(input["appData"])
    XCTAssertEqual(input["clientMutationId"] as? String, "")
  }
}
