import XCTest
@testable import KsApi

final class CommentTests: XCTestCase {

  func testJSONParsing_WithCompleteData() {

    let author = Author.decodeJSONDictionary([
      "author": [
        "id": 382491714,
        "name": "Nino Teixeira",
        "avatar": [
          "thumb": "https://ksr-qa-ugc.imgix.net/thumb.jpg",
          "small": "https://ksr-qa-ugc.imgix.net/small.jpg",
          "medium": "https://ksr-qa-ugc.imgix.net/medium.jpg"
        ],
        "urls": [
          "web": [
            "user": "https://staging.kickstarter.com/profile/382491714"
          ],
          "api": [
            "user": "https://api-staging.kickstarter.com/v1/users/382491714"
          ]
        ]
      ]
    ])

    XCTAssertNil(author.error)
    XCTAssertEqual(1, author.value?.id)
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
