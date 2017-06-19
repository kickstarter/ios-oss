import XCTest
@testable import KsApi
import Argo

internal final class MessageTests: XCTestCase {
  func testDecoding() {
    let result = Message.decodeJSONDictionary([
      "body": "Hello!",
      "created_at": 123456789.0,
      "id": 1,
      "recipient": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "img",
          "small": "img"
        ],
      ],
      "sender": [
        "id": 2,
        "name": "Clob",
        "avatar": [
          "medium": "img",
          "small": "img"
        ],
      ]
    ])

    XCTAssertNil(result.error)
    XCTAssertNotNil(result.value)
  }
}
