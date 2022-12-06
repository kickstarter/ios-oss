@testable import KsApi
import XCTest

internal final class MessageTests: XCTestCase {
  func testDecoding() {
    let result: Message! = Message.decodeJSONDictionary([
      "body": "Hello!",
      "created_at": 123_456_789.0,
      "id": 1,
      "recipient": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "img",
          "small": "img"
        ],
        "needs_password": true
      ],
      "sender": [
        "id": 2,
        "name": "Clob",
        "avatar": [
          "medium": "img",
          "small": "img"
        ],
        "needs_password": true
      ]
    ])

    XCTAssertNotNil(result)
  }
}
