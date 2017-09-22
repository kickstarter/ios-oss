@testable import KsApi
@testable import Library
import Prelude
import XCTest
/*
rootCategories: [KsApi.RootCategoriesEnvelope.Category(id: "Q2F0ZWdvcnktMQ==", name: "Art", parentId: nil, subcategories: KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection(totalCount: 12, nodes: [KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjg3", name: "Ceramics", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(6)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjA=", name: "Conceptual Art", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(6)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjE=", name: "Digital Art", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(15)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjI=", name: "Illustration", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(53)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjg4", name: "Installations", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(5)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktNTQ=", name: "Mixed Media", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(30)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjM=", name: "Painting", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(14)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjQ=", name: "Performance Art", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(9)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktNTM=", name: "Public Art", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(19)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjU=", name: "Sculpture", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(13)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjg5", name: "Textiles", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(5)), KsApi.RootCategoriesEnvelope.Category.SubcategoryConnection.Node(id: "Q2F0ZWdvcnktMjkw", name: "Video Art", parentId: "Q2F0ZWdvcnktMQ==", totalProjectCount: Optional(4))]), totalProjectCount: Optional(277)
 */

class GraphSchemaTests: XCTestCase {

  func testProjectUpdatesQuery() {
    let query = Query.rootCategories(
      .id +| [
        .name,
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
    XCTAssertEqual("rootCategories { id name subcategories { nodes { id name parentId totalProjectCount } totalCount } totalProjectCount }", query.description)
  }
}
