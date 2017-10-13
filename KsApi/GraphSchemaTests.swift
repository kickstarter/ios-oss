@testable import KsApi
@testable import Library
import Prelude
import XCTest

class GraphSchemaTests: XCTestCase {

  func testProjectUpdatesQuery() {
    let query = Query.rootCategories(
      .id +| [
        .name,
        .parentCategory,
        .subcategories(
          [],
          .totalCount +| [
            .nodes(
              .id +| [
                .name,
                .parentId,
                .totalProjectCount
              ]
            )
          ]
        ),
        .totalProjectCount
      ]
      )
    XCTAssertEqual("rootCategories { id name parentCategory { id name } subcategories { nodes { id name parentId totalProjectCount } totalCount } totalProjectCount }", query.description)
  }
}
