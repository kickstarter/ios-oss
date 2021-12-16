import Apollo
@testable import KsApi
import Prelude
import XCTest

final class Category_CategoryFragmentTests: XCTestCase {
  func test() {
    do {
      let variables: Apollo.GraphQLMap = [
        "id": "Q2F0ZWdvcnktMw=="
      ]
      let fragment = try GraphAPI.CategoryFragment(jsonObject: categoryDictionary(), variables: variables)
      XCTAssertNotNil(fragment)

      guard let category = Category.category(
        from: fragment,
        parentId: nil,
        subcategories: nil,
        totalProjectCount: nil
      ) else {
        XCTFail("category should be created from fragment")

        return
      }

      XCTAssertEqual(category.analyticsName, "Anthologies")
      XCTAssertEqual(category.id, "Q2F0ZWdvcnktMjQ5")
      XCTAssertEqual(category.name, "Anthologies")
      XCTAssertNil(category.parentId)
      XCTAssertNil(category.subcategories)
      XCTAssertEqual(category._parent?.analyticsName, "Comics")
      XCTAssertEqual(category._parent?.name, "Comics")
      XCTAssertEqual(category._parent?.id, "Q2F0ZWdvcnktMw==")
      XCTAssertNil(category.totalProjectCount)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
}

private func categoryDictionary() -> [String: Any] {
  let json = """
  {
    "__typename": "Category",
    "parentId": "Q2F0ZWdvcnktMw==",
    "totalProjectCount": 23,
    "id": "Q2F0ZWdvcnktMjQ5",
    "name": "Anthologies",
    "analyticsName": "Anthologies",
    "parentCategory": {
      "__typename": "Category",
      "id": "Q2F0ZWdvcnktMw==",
      "name": "Comics",
      "analyticsName": "Comics"
    }
  }
  """

  let data = Data(json.utf8)
  return (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]
}
