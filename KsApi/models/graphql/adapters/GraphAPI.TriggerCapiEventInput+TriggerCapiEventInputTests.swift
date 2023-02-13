@testable import KsApi
import XCTest

class GraphAPI_TriggerCapiEventInput_TriggerCapiEventInputTests: XCTestCase {
  func testTriggerCapiEventInputCreation_WithValidData_Success() {
    let input = TriggerCapiEventInput(
      projectId: "projectId",
      eventName: "eventName",
      externalId: "externalId",
      userEmail: "userEmail",
      appData: GraphAPI.AppDataInput(extinfo: ["appData"]),
      customData: GraphAPI.CustomDataInput(currency: nil, value: nil),
      waitForConsent: false
    )

    let graphInput = GraphAPI.TriggerCapiEventInput.from(input)

    XCTAssertEqual(graphInput.projectId, input.projectId)
    XCTAssertEqual(graphInput.eventName, input.eventName)
    XCTAssertEqual(graphInput.externalId, input.externalId)
    XCTAssertEqual(graphInput.userEmail, input.userEmail)
    XCTAssertEqual(graphInput.waitForConsent, input.waitForConsent)
    XCTAssertNotNil(input.appData)
    XCTAssertNotNil(input.customData)
  }
}
