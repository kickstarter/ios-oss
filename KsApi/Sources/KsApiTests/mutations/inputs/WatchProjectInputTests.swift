@testable import KsApi
import XCTest

final class WatchProjectInputTests: XCTestCase {
  func testInput() {
    let input = WatchProjectInput(
      clientMutationId: "clientMutationId",
      id: "projectId",
      trackingContext: "trackingContext"
    )

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["clientMutationId"] as? String, input.clientMutationId)
    XCTAssertEqual(inputDictionary["id"] as? String, input.id)
    XCTAssertEqual(inputDictionary["trackingContext"] as? String, input.trackingContext)
  }
}
