@testable import KsApi
import Prelude
import XCTest

final class Backing_GraphBackingTests: XCTestCase {
  func test() {
    // TODO: consider testing more variations
    XCTAssertNotNil(Backing.backing(from: .template))
  }

  func test_noReward() {
    let graphBacking = GraphBacking.template
      |> \.reward .~ nil

    let backing = Backing.backing(from: graphBacking)

    XCTAssertNotNil(backing)

    XCTAssertEqual(backing?.reward?.isNoReward, true)
  }
}
