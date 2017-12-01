import XCTest
@testable import KsApi
import Argo
import Prelude

class CategoryTests: XCTestCase {

  private var json: String {
       return  """
               {
                  "rootCategories": [ {
                     "id":"Q2F0ZWdvcnktMQ==",
                     "name":"Art",
                     "subcategories":{
                        "nodes": [{
                           "id":"Q2F0ZWdvcnktMjg3",
                           "name":"Ceramics",
                           "parentCategory":{
                              "id":"Q2F0ZWdvcnktMQ==",
                              "name":"Art"
                                            }
                                 }],
                     "parentId":"Q2F0ZWdvcnktMQ==",
                     "totalCount":8
                                      }
                                   } ]

                       }

               """
  }

  func testDecode_WithNilValues() {

    if let decodedData = categoriesFromJSON() {
        XCTAssertNotNil(decodedData.rootCategories)

        let category = decodedData.rootCategories[0]
        XCTAssertEqual(category.id, "Q2F0ZWdvcnktMQ==")
        XCTAssertEqual(category.name, "Art")
        XCTAssertNil(category.parent)
        XCTAssertNil(category.parentId)
    } else {
      XCTFail("Data should be decoded")
    }
  }

  func testDecode_Subcategories() {

    if let decodedData = categoriesFromJSON() {

      let category = decodedData.rootCategories.first
      let subcategory = category?.subcategories?.nodes.first
      XCTAssertNotNil(subcategory)
      XCTAssertEqual(subcategory?.id, "Q2F0ZWdvcnktMjg3")
      XCTAssertEqual(subcategory?.name, "Ceramics")
      XCTAssertEqual(subcategory?._parent?.id, "Q2F0ZWdvcnktMQ==")
      XCTAssertEqual(subcategory?._parent?.name, "Art")
    } else {
      XCTFail("Data should be decoded")
    }
}

  func testParent() {
    XCTAssertEqual(Category.illustration.parent, Category.art)
    XCTAssertEqual(Category.art.parent, nil)
  }

  func testParentCategoryType() {
    let parent = ParentCategory(id: Category.art.id,
                                name: Category.art.name)
    XCTAssertEqual(parent.categoryType, Category.illustration.parent)
  }

  func testSubcategory() {
    let subcategory = Category.illustration
    XCTAssertEqual(Category.art.subcategories?.nodes.first, subcategory)
  }

  func testRoot() {
    XCTAssertEqual(Category.illustration.root, Category.art)
    XCTAssertEqual(Category.illustration.isRoot, false)
    XCTAssertEqual(Category.art.root, Category.art)
    XCTAssertEqual(Category.art.isRoot, true)
    XCTAssertNil((Category.illustration
                  |> Category.lens.parent .~ nil).root,
      "A subcategory with no parent category present does not have a root."
    )
  }

  func testEquatable() {
    XCTAssertEqual(Category.art, Category.art)
    XCTAssertNotEqual(Category.art, Category.illustration)
  }

  func testDescription() {
    XCTAssertNotEqual(Category.art.description, "")
    XCTAssertNotEqual(Category.art.debugDescription, "")
  }

  func testIntID_invalidInput() {
    let art = Category.art
              |> Category.lens.id .~ "1"
    XCTAssertNil(art.intID, "intID should be resulted from a base64 decoded string")
  }

  func testIntID_validInput() {
    let art = Category.art
      |> Category.lens.id .~ "Q2F0ZWdvcnktMQ=="
    XCTAssertEqual(art.intID, 1)
  }

  private func categoriesFromJSON() -> RootCategoriesEnvelope? {
    if let jsonData = json.data(using: .utf8) {
      do {
        let decodedData = try JSONDecoder().decode(RootCategoriesEnvelope.self, from: jsonData)
        return decodedData
      } catch {
        return nil
      }
    }
    return nil
  }
}
