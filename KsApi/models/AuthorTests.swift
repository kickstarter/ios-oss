import XCTest
@testable import KsApi

final class CommentTests: XCTestCase {

  func testJSONParsing_WithCompleteData() {

    let author = Author.decodeJSONDictionary([
      "author": [
        "id": 382491714,
        "name": "Nino Teixeira",
        "avatar": [
          "thumb": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-1.1.0&w=40&h=40&fit=crop&v=&auto=format&frame=1&q=92&s=3982d46fcfc2fc8d69e5509b21c3e806",
          "small": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-1.1.0&w=160&h=160&fit=crop&v=&auto=format&frame=1&q=92&s=d84185902370c61b511043199eac445f",
          "medium": "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-1.1.0&w=160&h=160&fit=crop&v=&auto=format&frame=1&q=92&s=d84185902370c61b511043199eac445f"
        ],
        "urls": [
          "web": [
            "user": "https://staging.kickstarter.com/profile/382491714"
          ],
          "api": [
            "user": "https://api-staging.kickstarter.com/v1/users/382491714?signature=1545344614.b21b0a552cb7ced5bd93730812705796fe88f78d"
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
