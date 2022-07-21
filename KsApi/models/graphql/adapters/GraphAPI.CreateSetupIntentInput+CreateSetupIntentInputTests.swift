@testable import KsApi
import XCTest

class GraphAPI_CreateSetupIntentInput_CreateSetupIntentInputTests: XCTestCase {
  func testSetupIntentInputCreation_WithValidData_Success() {
    let input = CreateSetupIntentInput(projectId: "UHJvamVjdC0yMzEyODc5ODc")

    let graphInput = GraphAPI.CreateSetupIntentInput.from(input)

    XCTAssertEqual(graphInput.projectId, input.projectId)
  }
}
