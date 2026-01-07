@testable import KsApi
import Prelude
import XCTest

final class ItemTests: XCTestCase {
  func testDecoding() {
    let decoded: Item = try! Item.decodeJSONDictionary([
      "description": "Hello",
      "id": 1,
      "name": "The thing",
      "project_id": 1
    ])

    XCTAssertEqual("Hello", decoded.description)
    XCTAssertEqual(1, decoded.id)
    XCTAssertEqual("The thing", decoded.name)
    XCTAssertEqual(1, decoded.projectId)
  }
}
