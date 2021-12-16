import Foundation
@testable import KsApi
import XCTest

final class ProjectCategory_CategoryFragmentTests: XCTestCase {
  func test() {
    guard let categoryFragment = try? GraphAPI.CategoryFragment(
      jsonObject: categoryDictionary()
    ) else {
      XCTFail("should create a category fragment")

      return
    }

    let category = Project.Category.category(from: categoryFragment)

    XCTAssertEqual(category?.id, 47)
    XCTAssertEqual(category?.name, "My Category")
    XCTAssertEqual(category?.analyticsName, "Photobooks")
    XCTAssertEqual(category?.parentAnalyticsName, "Parent /Category")
    XCTAssertEqual(category?.parentId, 18)
    XCTAssertEqual(category?.parentName, "My Parent Category")
  }

  private func categoryDictionary() -> [String: Any] {
    let json = """
    {
      "parentCategory": {
        "__typename": "Category",
        "id": "Q2F0ZWdvcnktMTg=",
        "name": "My Parent Category",
        "analyticsName": "Parent /Category"
      },
      "__typename": "Category",
      "id": "Q2F0ZWdvcnktNDc=",
      "name": "My Category",
      "analyticsName": "Photobooks"
    }
    """

    let data = Data(json.utf8)
    let resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    return resultMap
  }
}
