@testable import KsApi
import XCTest

class GraphAPI_CreateFlaggingInput_CreateFlaggingInputTests: XCTestCase {
  func testCreateFlaggingInputCreation_WithValidData_Success() {
    let input =
      CreateFlaggingInput(
        contentId: "contentId",
        kind: GraphAPI.NonDeprecatedFlaggingKind.prohibitedItems,
        details: "details",
        clientMutationId: ""
      )

    let graphInput = GraphAPI.CreateFlaggingInput.from(input)

    XCTAssertEqual(graphInput.contentId, input.contentId)
    XCTAssertEqual(graphInput.kind, input.kind)
    XCTAssertEqual(graphInput.details, input.details)
    XCTAssertEqual(graphInput.clientMutationId, input.clientMutationId)
  }
}
