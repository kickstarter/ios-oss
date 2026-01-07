@testable import KsApi
import XCTest

final class GraphCommentTests: XCTestCase {
  func testDecode() {
    let expectedCreatedAt: TimeInterval = 1_622_067_124
    let expectedImageURL =
      "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=200&origin=ugc-qa&q=92&width=200&sig=hCxjTNPjsj1RjnPaahuVIrBSb1iEgJHJ8g%2FyXiMpZWI%3D"
    let expectedAuthorName = "James Bond"
    let expectedAuthorId = "VXNlci0xOTE1MDY0NDY3"
    let expectedCommentId = "Q29tbWVudC0zMDQ5MDQ2NA=="
    let expectedCommentBody = "I have not received a survey yet either."
    let expectedReplyTotalCount = 5
    let expectedAuthorBadge = "superbacker"

    let dictionary: [String: Any] =
      [
        "author": [
          "id": expectedAuthorId,
          "isBlocked": nil,
          "isCreator": nil,
          "name": expectedAuthorName,
          "imageUrl": expectedImageURL
        ],
        "authorBadges": [expectedAuthorBadge],
        "body": expectedCommentBody,
        "id": expectedCommentId,
        "deleted": false,
        "createdAt": expectedCreatedAt,
        "replies": [
          "totalCount": expectedReplyTotalCount
        ]
      ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let comment = try? JSONDecoder().decode(GraphComment.self, from: data)

    XCTAssertEqual(comment!.body, expectedCommentBody)
    XCTAssertFalse(comment!.deleted)
    XCTAssertEqual(comment!.createdAt, expectedCreatedAt)
    XCTAssertEqual(comment!.authorBadges, [.superbacker])
    XCTAssertEqual(comment!.id, expectedCommentId)
    XCTAssertEqual(comment!.replyCount, 5)
    XCTAssertEqual(comment!.author.id, decompose(id: expectedAuthorId)?.description)
    XCTAssertEqual(comment!.author.isBlocked, false)
    XCTAssertEqual(comment!.author.isCreator, false)
    XCTAssertEqual(comment!.author.name, expectedAuthorName)
    XCTAssertEqual(comment!.author.imageUrl, expectedImageURL)
  }
}
