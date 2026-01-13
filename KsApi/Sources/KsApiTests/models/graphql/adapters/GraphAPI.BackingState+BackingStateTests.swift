import GraphAPI
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

final class GraphAPI_BackingState_BackingStateTests: XCTestCase {
  func testErroredState_Success() {
    XCTAssertEqual(
      GraphAPI.BackingState(rawValue: "errored"),
      GraphAPI.BackingState.from(BackingState.errored)
    )
  }
}
