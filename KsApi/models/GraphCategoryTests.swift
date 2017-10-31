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
      XCTFail()
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
      XCTFail()
    }
}

  func testParent() {
    XCTAssertEqual(RootCategoriesEnvelope.Category.illustration.parent, RootCategoriesEnvelope.Category.art)
    XCTAssertEqual(RootCategoriesEnvelope.Category.art.parent, nil)
  }

  func testParentCategoryType() {
    let parent = ParentCategory(id: RootCategoriesEnvelope.Category.art.id,
                                name: RootCategoriesEnvelope.Category.art.name)
    XCTAssertEqual(parent.categoryType, RootCategoriesEnvelope.Category.illustration.parent)
  }

  func testSubcategory() {
    let subcategory = RootCategoriesEnvelope.Category.illustration
    XCTAssertEqual(RootCategoriesEnvelope.Category.art.subcategories?.nodes.first, subcategory)
  }

  func testRoot() {
    XCTAssertEqual(RootCategoriesEnvelope.Category.illustration.root, RootCategoriesEnvelope.Category.art)
    XCTAssertEqual(RootCategoriesEnvelope.Category.illustration.isRoot, false)
    XCTAssertEqual(RootCategoriesEnvelope.Category.art.root, RootCategoriesEnvelope.Category.art)
    XCTAssertEqual(RootCategoriesEnvelope.Category.art.isRoot, true)
    XCTAssertNil((RootCategoriesEnvelope.Category.illustration
                  |> RootCategoriesEnvelope.Category.lens.parent .~ nil).root,
      "A subcategory with no parent category present does not have a root."
    )
  }

  func testEquatable() {
    XCTAssertEqual(RootCategoriesEnvelope.Category.art, RootCategoriesEnvelope.Category.art)
    XCTAssertNotEqual(RootCategoriesEnvelope.Category.art, RootCategoriesEnvelope.Category.illustration)
  }

  func testDescription() {
    XCTAssertNotEqual(RootCategoriesEnvelope.Category.art.description, "")
    XCTAssertNotEqual(RootCategoriesEnvelope.Category.art.debugDescription, "")
  }

  func testIntID_invalidInput() {
    let art = RootCategoriesEnvelope.Category.art
              |> RootCategoriesEnvelope.Category.lens.id .~ "1"
    XCTAssertNil(art.intID, "intID should be resulted from a base64 decoded string")
  }

  func testIntID_validInput() {
    let art = RootCategoriesEnvelope.Category.art
      |> RootCategoriesEnvelope.Category.lens.id .~ "Q2F0ZWdvcnktMQ=="
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
