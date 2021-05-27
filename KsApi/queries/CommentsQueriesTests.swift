@testable import KsApi
import XCTest

final class CommentsQueriesTests: XCTestCase {
  func testCommentsQuery() {
    let queryString = Query.build(commentsQuery(withProjectSlug: "project-slug", after: "end-cursor"))
    print("*** \(queryString)")
    XCTAssertEqual(
      queryString,
      """
      { project(slug: "project-slug") { comments(after: "end-cursor" first: 25) { edges { node { author { id imageUrl(width: 200) isCreator name } authorBadges body createdAt deleted id replies { totalCount } } } pageInfo { endCursor hasNextPage } totalCount } id slug } }
      """
    )
  }
}

