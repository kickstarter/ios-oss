import Apollo
@testable import KsApi
import XCTest

final class RootCategoryEnvelope_FetchRootCategoriesEnvelopeQueryDataTests: XCTestCase {
  func testFetchCategoriesQueryData_Success() {
    let producer = RootCategoriesEnvelope.envelopeProducer(from: FetchRootCategoriesQueryTemplate.valid.data)
    guard let rootCategories = MockGraphQLClient.shared.client.data(from: producer)?.rootCategories else {
      XCTFail()

      return
    }

    XCTAssertEqual(rootCategories.count, 2)

    guard let firstRootCategory = rootCategories.first else {
      XCTFail("first subcategory should exist.")

      return
    }

    XCTAssertEqual(firstRootCategory.analyticsName, "Art")
    XCTAssertEqual(firstRootCategory.id, "Q2F0ZWdvcnktMQ==")
    XCTAssertEqual(firstRootCategory.name, "Art")
    XCTAssertEqual(firstRootCategory.totalProjectCount, 348)
    XCTAssertEqual(firstRootCategory.subcategories?.totalCount, 13)

    guard let firstSubcategory = firstRootCategory.subcategories?.nodes.first else {
      XCTFail("first subcategory should exist.")

      return
    }

    XCTAssertEqual(firstSubcategory.parentId, "Q2F0ZWdvcnktMQ==")
    XCTAssertEqual(firstSubcategory.totalProjectCount, 3)
    XCTAssertEqual(firstSubcategory.id, "Q2F0ZWdvcnktMjg3")
    XCTAssertEqual(firstSubcategory.name, "Ceramics")
    XCTAssertEqual(firstSubcategory.analyticsName, "Ceramics")
    XCTAssertEqual(firstSubcategory._parent?.id, "Q2F0ZWdvcnktMQ==")
    XCTAssertEqual(firstSubcategory._parent?.name, "Art")
    XCTAssertEqual(firstSubcategory._parent?.analyticsName, "Art")
  }
}
