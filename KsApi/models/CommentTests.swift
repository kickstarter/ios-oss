import XCTest
@testable import KsApi

final class CommentTests: XCTestCase {

  func testJSONParsing_WithCompleteData() {

    let comment = Comment.decodeJSONDictionary([
      "author": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ]
      ],
      "body": "hello!",
      "created_at": 123456789.0,
      "deleted_at": 123456789.0,
      "id": 1
      ])

    XCTAssertNil(comment.error)
    XCTAssertEqual(1, comment.value?.id)
  }

  func testJSONParsing_ZeroDeletedAt() {

    let comment = Comment.decodeJSONDictionary([
      "author": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ]
      ],
      "body": "hello!",
      "created_at": 123456789.0,
      "deleted_at": 0,
      "id": 1
      ])

    XCTAssertNil(comment.error)
    XCTAssertNotNil(comment.value)
    XCTAssertNil(comment.value?.deletedAt)
  }
}
