import Apollo
@testable import KsApi
import XCTest

final class Category_FetchCategoryQueryDataTests: XCTestCase {
  func testFetchCategoryQueryData_Success() {
    let producer = CategoryEnvelope.envelopeProducer(from: FetchCategoryQueryTemplate.valid.data)
    guard let envelope = MockGraphQLClient.shared.client.data(from: producer)?.node else {
      XCTFail()

      return
    }

    XCTAssertEqual(envelope.analyticsName, "Comics")
    XCTAssertEqual(envelope.id, "Q2F0ZWdvcnktMw==")
    XCTAssertEqual(envelope.name, "Comics")
    XCTAssertEqual(envelope.totalProjectCount, 306)
    XCTAssertEqual(envelope.subcategories?.totalCount, 5)

    guard let firstSubcategory = envelope.subcategories?.nodes.first else {
      XCTFail("first subcategory should exist.")

      return
    }

    XCTAssertEqual(firstSubcategory.parentId, "Q2F0ZWdvcnktMw==")
    XCTAssertEqual(firstSubcategory.totalProjectCount, 23)
    XCTAssertEqual(firstSubcategory.id, "Q2F0ZWdvcnktMjQ5")
    XCTAssertEqual(firstSubcategory.name, "Anthologies")
    XCTAssertEqual(firstSubcategory.analyticsName, "Anthologies")
    XCTAssertEqual(firstSubcategory._parent?.id, "Q2F0ZWdvcnktMw==")
    XCTAssertEqual(firstSubcategory._parent?.name, "Comics")
    XCTAssertEqual(firstSubcategory._parent?.analyticsName, "Comics")
  }
}
