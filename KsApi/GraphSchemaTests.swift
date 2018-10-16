@testable import KsApi
@testable import Library
import Prelude
import XCTest

class GraphSchemaTests: XCTestCase {

  func testRootCategoriesQuery() {
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
    XCTAssertEqual("rootCategories { id name parentCategory { id name } " +
                   "subcategories { nodes { id name parentId totalProjectCount } totalCount } " +
                   "totalProjectCount }", query.description)
  }

  func testUserQuery() {
    let query = Query.user(.id +| [
      .name,
      .email,
      .biography,
      .userId,
      .image(alias: "avatarSmall", width: 25),
      .newletterSubscriptions(.alumniNewsletter +| [.artsCultureNewsletter]),
      .savedProjects([], .totalCount +| []),
      .url
      ])

    let expectedQuery = """
                        me { avatarSmall: imageUrl(width: 25) biography email id name \
                        newslettersSubscriptions { alumniNewsletter artsCultureNewsletter } \
                        savedProjects { totalCount } uid url }
                        """

    XCTAssertEqual(expectedQuery, query.description)
  }
}
