@testable import KsApi
import XCTest

final class User_GraphUserTests: XCTestCase {
  func test() {
    // TODO: consider testing more variations
    XCTAssertNotNil(User.user(from: .template))
  }
}
