@testable import KsApi
import XCTest

final class CreateFlaggingInputTests: XCTestCase {
  func testCreateFlaggingInputTestsDictionary_WithValue_Success() {
    let createFlaggingInput =
      CreateFlaggingInput(
        contentId: "contentId",
        kind: GraphAPI.NonDeprecatedFlaggingKind.prohibitedItems,
        details: "details",
        clientMutationId: ""
      )

    let input = createFlaggingInput.toInputDictionary()

    XCTAssertEqual(input["contentId"] as? String, "contentId")
    XCTAssertEqual(
      input["kind"] as? GraphAPI.NonDeprecatedFlaggingKind,
      GraphAPI.NonDeprecatedFlaggingKind.prohibitedItems
    )
    XCTAssertEqual(input["details"] as? String, "details")
    XCTAssertEqual(input["clientMutationId"] as? String, "")
  }
}
