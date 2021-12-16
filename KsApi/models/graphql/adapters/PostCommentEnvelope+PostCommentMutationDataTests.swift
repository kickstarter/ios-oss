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
      "https://ksr-qa-ugc.imgix.net/missing_user_avatar.png?ixlib=rb-4.0.2&w=200&h=200&fit=crop&v=&auto=format&frame=1&q=92&s=e5c4e9017b28bb95181ff20d61b17f99"
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
