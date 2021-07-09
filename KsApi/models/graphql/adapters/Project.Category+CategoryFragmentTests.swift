import Foundation
@testable import KsApi
import XCTest

final class Category_CategoryFragmentTests: XCTestCase {
  func test() {
    let categoryFragment = GraphAPI.CategoryFragment(
      id: "Q2F0ZWdvcnktNDc=",
      name: "My Category",
      parentCategory: .init(
        id: "Q2F0ZWdvcnktMTg=",
        name: "My Parent Category"
      )
    )

    let category = Project.Category.category(from: categoryFragment)

    XCTAssertEqual(category?.id, 47)
    XCTAssertEqual(category?.name, "My Category")
    XCTAssertEqual(category?.parentId, 18)
    XCTAssertEqual(category?.parentName, "My Parent Category")
  }
}
