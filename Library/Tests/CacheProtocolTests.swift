import XCTest
@testable import Library

final class CacheProtocolTests: XCTestCase {

  func testMockCache() {
    let cache = MockCache()

    cache["lucky_number"] = 14

    XCTAssertEqual(14, cache["lucky_number"])

    cache["lucky_string"] = "14"

    XCTAssertEqual("14", cache["lucky_string"])

    cache["someBool"] = true

    XCTAssertEqual(true, cache["someBool"])

    cache["someBool"] = nil

    XCTAssertNil(cache["someBool"])

    cache.removeAllObjects()

    XCTAssertNil(cache["lucky_number"])
    XCTAssertNil(cache["lucky_string"])
  }
}
