@testable import KsApi
import XCTest

final class TriggerCapiEventInputTests: XCTestCase {
  func testTriggerCapiEventInputTestsDictionary_WithValue_Success() {
    let triggerCapiEventInput =
      TriggerCapiEventInput(
        projectId: "projId",
        eventName: "eventName",
        externalId: "extId",
        userEmail: "userEmail",
        appData: GraphAPI.AppDataInput(advertiserTrackingEnabled: true,
                                       applicationTrackingEnabled: true,
                                       extinfo: ["appData"]),
        customData: GraphAPI.CustomDataInput(currency: nil, value: nil)
      )

    let input = triggerCapiEventInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "projId")
    XCTAssertEqual(input["eventName"] as? String, "eventName")
    XCTAssertEqual(input["externalId"] as? String, "extId")
    XCTAssertEqual(input["userEmail"] as? String, "userEmail")
    XCTAssertNotNil(input["appData"])
    XCTAssertNotNil(input["customData"])
  }
}
