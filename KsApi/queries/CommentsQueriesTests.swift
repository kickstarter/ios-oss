@testable import KsApi
import XCTest

final class CommentsQueriesTests: XCTestCase {
  func testCommentsQuery() {
    let queryString = Query.build(comments(withProjectSlug: "project-slug", after: "end-cursor"))

    XCTAssertEqual(
      queryString,
      """
      { project(slug: "project-slug") { comments(after: "end-cursor" first: 25) { edges { node { author { id isCreator name } body id replies { totalCount } } } pageInfo { endCursor hasNextPage } totalCount } id } }
      """
    )
  }
}
