@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

final class ActivityCommentTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let comment: ActivityComment! = ActivityComment.decodeJSONDictionary([
      "author": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "thumb": "http://www.kickstarter.com/thumb.jpg",
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ],
        "urls": [
          "web": [
            "user": "https://stg.ksr.io/profile/382491714"
          ],
          "api": [
            "user": "https://api.stg.ksr.io/v1/users/382491714"
          ]
        ]
      ],
      "body": "hello!",
      "created_at": 123_456_789.0,
      "deleted_at": 123_456_789.0,
      "id": 1
    ])

    XCTAssertNotNil(comment)
    XCTAssertEqual(1, comment.id)
  }

  func testJSONParsing_ZeroDeletedAt() {
    let comment: ActivityComment! = ActivityComment.decodeJSONDictionary([
      "author": [
        "id": 1,
        "name": "Blob",
        "avatar": [
          "thumb": "http://www.kickstarter.com/thumb.jpg",
          "medium": "http://www.kickstarter.com/medium.jpg",
          "small": "http://www.kickstarter.com/small.jpg"
        ],
        "urls": [
          "web": [
            "user": "https://stg.ksr.io/profile/382491714"
          ],
          "api": [
            "user": "https://api.stg.ksr.io/v1/users/382491714"
          ]
        ]
      ],
      "body": "hello!",
      "created_at": 123_456_789.0,
      "deleted_at": 0,
      "id": 1
    ])

    XCTAssertNotNil(comment)
    XCTAssertNil(comment.deletedAt)
  }
}
