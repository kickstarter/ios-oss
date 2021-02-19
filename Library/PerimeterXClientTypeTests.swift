@testable import KsApi
import Prelude
import XCTest

final class PerimeterXClientTypeTests: TestCase {
  func testHeaders_NoError() {
    let mockPXClient = MockPerimeterXClient()

    XCTAssertEqual(mockPXClient.headers(), ["PX-AUTH-TEST": "foobar"])
  }

  func testHeaders_IncorrectHeader() {
    let mockPXClient = MockPerimeterXClient()

    XCTAssertNotEqual(mockPXClient.headers(), ["PX-INCORRECT-HEADER": "foobar"])
  }
}
