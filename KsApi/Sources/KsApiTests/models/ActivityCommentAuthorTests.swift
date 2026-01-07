@testable import KsApi
import XCTest

final class ActivityCommentAuthorTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let author: ActivityCommentAuthor! = ActivityCommentAuthor.decodeJSONDictionary([
      "id": 382_491_714,
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
    ])

    XCTAssertNotNil(author)
    XCTAssertEqual(382_491_714, author.id)
  }

  func testJSONParsing_WithIncompleteData() {
    let author: ActivityComment! = ActivityComment.decodeJSONDictionary([
      "id": 1,
      "name": "Blob",
      "avatar": [
        "medium": "http://www.kickstarter.com/medium.jpg",
        "small": "http://www.kickstarter.com/small.jpg"
      ]
    ])
    XCTAssertNil(author)
  }

  func testJSONParsing_SwiftDecoder() {
    let jsonString = """
    {
      "id": 382491714,
      "name": "Nino Teixeira",
      "avatar": {
        "thumb": "https://ksr-qa-ugc.imgix.net/thumb_avatar.png",
        "small": "https://ksr-qa-ugc.imgix.net/small_avatar.png",
        "medium": "https://ksr-qa-ugc.imgix.net/medium_avatar.png"
        },
      "urls": {
        "web": {
          "user": "https://staging.kickstarter.com/profile/382491714"
        },
        "api": {
          "user": "https://api-staging.kickstarter.com/v1/users/382491714"
        }
      }
    }
    """

    let data = jsonString.data(using: .utf8)!
    let author = try? JSONDecoder().decode(ActivityCommentAuthor.self, from: data)

    XCTAssertEqual(author?.id, 382_491_714)
    XCTAssertEqual(author?.name, "Nino Teixeira")
  }
}
