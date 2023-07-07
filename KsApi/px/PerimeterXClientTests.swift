@testable import KsApi
import PerimeterX_SDK
import Prelude
import XCTest

final class PerimeterXClientTests: XCTestCase {
  func testCookie() {
    let client = PerimeterXClient(dateType: ApiMockDate.self)

    guard let cookie = client.cookie else {
      XCTFail("Where's my cookie?")
      return
    }

    XCTAssertEqual(cookie.domain, "www.perimeterx.com")
    XCTAssertEqual(cookie.path, "/")
    XCTAssertEqual(cookie.name, "_pxmvid")
    XCTAssertEqual(cookie.value, client.vid)
    XCTAssertEqual(cookie.expiresDate, ApiMockDate.init(timeIntervalSinceNow: 3_600).date)
  }
}
