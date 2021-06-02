@testable import KsApi
import XCTest

final class CommentsQueriesTests: XCTestCase {
  func testCommentsQuery() {
    let queryString = Query.build(commentsQuery(withProjectSlug: "project-slug", after: "end-cursor"))
    XCTAssertEqual(
      queryString,
      """
      { project(slug: "project-slug") { comments(after: "end-cursor" first: 25) { edges { node { author { id imageUrl(width: 200) isCreator name } authorBadges body createdAt deleted id parentId replies { totalCount } } } pageInfo { endCursor hasNextPage } totalCount } id slug } }
      """
    )
  }

  func testCommentRepliesQuery() {
    let query = commentRepliesQuery(withCommentId: "comment-id", before: "before-cursor")
    let queryString = Query.build(query)

    XCTAssertEqual(
      queryString,
      """
      { comment: node(id: "comment-id") { ... on Comment { author { id imageUrl(width: 200) isCreator name } authorBadges body createdAt deleted id parentId replies(before: "before-cursor" last: 25) { edges { node { author { id imageUrl(width: 200) isCreator name } authorBadges body createdAt deleted id parentId } } pageInfo { hasPreviousPage startCursor } totalCount } } } }
      """
    )
  }
}
