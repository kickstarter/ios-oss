@testable import KsApi
import XCTest

final class GraphAPI_BackingState_BackingStateTests: XCTestCase {
  func test() {
    XCTAssertEqual(
      GraphAPI.BackingState(rawValue: "errored"),
      GraphAPI.BackingState.from(BackingState.errored)
    )
  }
}
