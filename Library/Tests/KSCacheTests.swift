import XCTest
@testable import Library

final class KSCacheTests: XCTestCase {

  func testCache() {
    let cache = KSCache()

    cache["lucky_number"] = 14

    XCTAssertEqual(14, cache["lucky_number"] as? Int)

    cache["lucky_string"] = "14"

    XCTAssertEqual("14", cache["lucky_string"] as? String)

    cache["someBool"] = true

    XCTAssertEqual(true, cache["someBool"] as? Bool)

    cache["someBool"] = nil

    XCTAssertNil(cache["someBool"])

    cache.removeAllObjects()

    XCTAssertNil(cache["lucky_number"])
    XCTAssertNil(cache["lucky_string"])
  }
}
