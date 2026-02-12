import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

class GraphAPI_BlockUserInput_BlockUserInputTests: XCTestCase {
  func testInput() {
    let input = BlockUserInput(blockUserId: "123")
    let graphInput = GraphAPI.BlockUserInput.from(input)

    XCTAssertEqual(graphInput.blockUserId, input.blockUserId)
  }
}
