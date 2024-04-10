@testable import KsApi
import XCTest

final class PostCommentEnvelope_PostCommentMutationDataTests: XCTestCase {
  func testPostCommentEnvelope_Success() {
    let producer = PostCommentEnvelope.producer(from: PostCommentMutationTemplate.valid.data)

    guard let createCommentEnvelope = MockGraphQLClient.shared.client.data(from: producer) else {
      XCTFail()

      return
    }

    XCTAssertEqual(
      createCommentEnvelope.author.id,
      "618005886"
    )
    XCTAssertEqual(
      createCommentEnvelope.author.imageUrl,
      "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=200&origin=ugc-qa&q=92&width=200&sig=hCxjTNPjsj1RjnPaahuVIrBSb1iEgJHJ8g%2FyXiMpZWI%3D"
    )
    XCTAssertFalse(createCommentEnvelope.author.isCreator)
    XCTAssertEqual(createCommentEnvelope.author.name, "Some author")
    XCTAssertEqual(createCommentEnvelope.authorBadges, [.superbacker])
    XCTAssertEqual(decompose(id: createCommentEnvelope.id), decompose(id: "Q29tbWVudC0zNDQ3MjY2MQ=="))

    guard let parentId = createCommentEnvelope.parentId else {
      XCTFail()

      return
    }

    XCTAssertEqual(decompose(id: parentId), decompose(id: "Q29tbWVudC0zNDQ3MjY1OQ=="))
    XCTAssertEqual(createCommentEnvelope.createdAt, Double(1_636_499_465))
    XCTAssertFalse(createCommentEnvelope.isDeleted)
    XCTAssertEqual(createCommentEnvelope.replyCount, 0)
  }
}
