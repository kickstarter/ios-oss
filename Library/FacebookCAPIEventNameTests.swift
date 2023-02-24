@testable import KsApi
@testable import Library
import XCTest

final class FacebookCAPIEventNameTests: XCTestCase {
  func testCreateMutationInput() {
    let mutationInput = FacebookCAPIEventService
      .createMutationInput(
        for: .ViewContent,
        projectId: "projId",
        externalId: "extId",
        userEmail: "email",
        currency: "currency",
        value: "value"
      )

    let dict = mutationInput.toInputDictionary()

    XCTAssertEqual(dict["eventName"] as! String, FacebookCAPIEventName.ViewContent.rawValue)
    XCTAssertEqual(dict["projectId"] as! String, "projId")
    XCTAssertEqual(dict["externalId"] as! String, "extId")
    XCTAssertEqual(dict["userEmail"] as! String, "email")
    XCTAssertNotNil(dict["appData"])
    XCTAssertNotNil(dict["customData"])
  }
}
