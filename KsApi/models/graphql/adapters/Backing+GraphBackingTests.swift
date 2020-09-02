@testable import KsApi
import XCTest

final class Backing_GraphBackingTests: XCTestCase {
  func test() {
    // TODO: consider testing more variations
    XCTAssertNotNil(Backing.backing(from: .template))
  }
}
