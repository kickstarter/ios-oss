import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class PostCommentEnvelope_PostCommentMutationDataTests: XCTestCase {
  func testPostCommentEnvelope_Success() {
    let mock = Mock<GraphAPITestMocks.Mutation>()
    mock.createComment = Mock<GraphAPITestMocks.PostCommentPayload>()
    mock.createComment?.comment = Mock<GraphAPITestMocks.Comment>()
    mock.createComment?.comment?.author = Mock<GraphAPITestMocks.User>()
    mock.createComment?.comment?.author?.id = "VXNlci02MTgwMDU4ODY="
    mock.createComment?.comment?.author?
      .imageUrl =
      "https://i.kickstarter.com/missing_user_avatar.png?anim=false&fit=crop&height=200&origin=ugc-qa&q=92&width=200&sig=hCxjTNPjsj1RjnPaahuVIrBSb1iEgJHJ8g%2FyXiMpZWI%3D"
    mock.createComment?.comment?.author?.isCreator = false
    mock.createComment?.comment?.author?.name = "Some author"
    mock.createComment?.comment?.authorBadges = [
      .case(GraphAPI.CommentBadge.superbacker)
    ]
    mock.createComment?.comment?.body = "body test"
    mock.createComment?.comment?.id = "Q29tbWVudC0zNDQ3MjY2MQ=="
    mock.createComment?.comment?.parentId = "Q29tbWVudC0zNDQ3MjY1OQ=="
    mock.createComment?.comment?.createdAt = "1636499465"
    mock.createComment?.comment?.deleted = false
    mock.createComment?.comment?.replies = Mock<GraphAPITestMocks.CommentConnection>()
    mock.createComment?.comment?.replies?.totalCount = 0
    mock.createComment?.comment?.hasFlaggings = false
    mock.createComment?.comment?.removedPerGuidelines = false
    mock.createComment?.comment?.sustained = false

    let data = GraphAPI.PostCommentMutation.Data.from(mock)

    let producer = PostCommentEnvelope.producer(from: data)

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
