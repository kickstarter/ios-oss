@testable import KsApi
import XCTest

final class CommentsQueriesTests: XCTestCase {
  func testCommentRepliesQuery() {
    let query = commentRepliesQuery(withCommentId: "comment-id", before: "before-cursor")
    let queryString = Query.build(query)

    XCTAssertEqual(
      queryString,
      """
      { comment: node(id: "comment-id") { ... on Comment { author { id imageUrl(width: 200) isCreator name } authorBadges body createdAt deleted id parentId replies(before: "before-cursor" last: 7) { edges { node { author { id imageUrl(width: 200) isCreator name } authorBadges body createdAt deleted id parentId } } pageInfo { hasPreviousPage startCursor } totalCount } } } }
      """
    )
  }
}
