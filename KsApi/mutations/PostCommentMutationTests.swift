@testable import KsApi
import XCTest

final class PostCommentMutationTests: XCTestCase {
  func testPostRootCommentMutationProperties() {
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
            parentId
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

  func testPostReplyMutationProperties() {
    let input = PostCommentInput(
      body: "Hello World",
      commentableId: "a89SFHAs89hf=",
      parentId: "o85hUTAXz670p="
    )
    let mutation = PostCommentMutation(input: input)

    XCTAssertEqual(mutation.input.parentId, "o85hUTAXz670p=")
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
            parentId
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
