@testable import KsApi
import XCTest

final class PostCommentMutationTests: XCTestCase {
  func testMutationProperties() {
    let input = PostCommentInput(body: "Hello World", commentableId: "a89SFHAs89hf=")
    let mutation = PostCommentMutation(input: input)

    XCTAssertNil(mutation.input.parentId)
    XCTAssertEqual(mutation.input.body, "Hello World")
    XCTAssertEqual(mutation.input.commentableId, "a89SFHAs89hf=")
    XCTAssertEqual(
      mutation.description,
      """
      mutation ($input: PostCommentInput!) {
        createComment(input: $input) {
          comment {
            author {
              id
              imageUrl(width: 200)
              isCreator
              name
            }
            authorBadges
            body
            createdAt
            deleted
            id
            replies {
              totalCount
            }
          }
        }
      }
      """
    )
  }
}
