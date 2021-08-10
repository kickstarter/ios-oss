@testable import KsApi
import XCTest

class GraphAPI_UnwatchProjectInput_WatchProjectInputTests: XCTestCase {
  func testInput() {
    let input = WatchProjectInput(
      clientMutationId: "client-mutation-id",
      id: "project-id",
      trackingContext: "tracking-context"
    )

    let graphInput = GraphAPI.UnwatchProjectInput.from(input)

    XCTAssertEqual(graphInput.clientMutationId, input.clientMutationId)
    XCTAssertEqual(graphInput.id, input.id)
    XCTAssertEqual(graphInput.trackingContext, input.trackingContext)
  }
}
