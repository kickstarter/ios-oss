@testable import KsApi
import Prelude
import XCTest

class CategoryTests: XCTestCase {
  private var json: String {
    let json = """
    {
      "rootCategories": [
        {
          "analyticsName": "Art",
          "id": "Q2F0ZWdvcnktMQ==",
          "name": "Art",
          "subcategories": {
            "nodes": [
              {
                "analyticsName": "Ceramics",
                "id": "Q2F0ZWdvcnktMjg3",
                "name": "Ceramics",
                "parentCategory": {
                  "analyticsName": "Art",
                  "id": "Q2F0ZWdvcnktMQ==",
                  "name": "Art"
                }
              }
            ],
            "parentId": "Q2F0ZWdvcnktMQ==",
            "totalCount": 8
          }
        }
      ]
    }
    """

    return json
  }

  func testDecode_WithNilValues() {
    if let decodedData = categoriesFromJSON() {
      XCTAssertNotNil(decodedData.rootCategories)

      let category = decodedData.rootCategories[0]
      XCTAssertEqual(category.analyticsName, "Art")
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
      XCTAssertEqual(subcategory?.analyticsName, "Ceramics")
      XCTAssertEqual(subcategory?._parent?.id, "Q2F0ZWdvcnktMQ==")
      XCTAssertEqual(subcategory?._parent?.name, "Art")
      XCTAssertEqual(subcategory?._parent?.analyticsName, "Art")
    } else {
      XCTFail("Data should be decoded")
    }
  }

  func testEncode_Subcategory() {
    let category = Category.tabletopGames
    if let data = try? JSONEncoder().encode(category) {
      XCTAssertNotNil(data)

      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

      XCTAssertEqual("Tabletop Games", json?["analyticsName"] as? String)
      XCTAssertEqual("Q2F0ZWdvcnktMzQ=", json?["id"] as? String)
      XCTAssertEqual("Tabletop Games", json?["name"] as? String)
      XCTAssertEqual("Q2F0ZWdvcnktMTI=", json?["parentId"] as? String)
      XCTAssertEqual([
        "analyticsName": "Games",
        "id": "Q2F0ZWdvcnktMTI=",
        "name": "Games"
      ], json?["parentCategory"] as? [String: String])
      XCTAssertNil(json?["subcategories"])
      XCTAssertNil(json?["totalProjectCount"])
    } else {
      XCTFail("Data should be encoded")
    }
  }

  func testEncode_ParentCategory() {
    let category = Category.art
    if let data = try? JSONEncoder().encode(category) {
      XCTAssertNotNil(data)

      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

      XCTAssertEqual("Art", json?["analyticsName"] as? String)
      XCTAssertEqual("Q2F0ZWdvcnktMQ==", json?["id"] as? String)
      XCTAssertEqual("Art", json?["name"] as? String)
      XCTAssertNil(json?["totalProjectCount"])
      XCTAssertNil(json?["parentCategory"])
      XCTAssertNil(json?["parentId"])

      let subcategories = json?["subcategories"] as? [String: Any]
      let nodes = subcategories?["nodes"] as? [[String: Any]]

      XCTAssertEqual(1, subcategories?["totalCount"] as? Int)
      XCTAssertEqual("Illustration", nodes?.first?["name"] as? String)
      XCTAssertEqual("Q2F0ZWdvcnktMjI=", nodes?.first?["id"] as? String)
      XCTAssertEqual([
        "analyticsName": "Art",
        "id": "Q2F0ZWdvcnktMQ==",
        "name": "Art"
      ], nodes?.first?["parentCategory"] as? [String: String])
      XCTAssertEqual("Q2F0ZWdvcnktMQ==", nodes?.first?["parentId"] as? String)
      XCTAssertNil(nodes?.first?["totalProjectCount"])
    } else {
      XCTFail("Data should be encoded")
    }
  }

  func testParent() {
    XCTAssertEqual(Category.illustration.parent, Category.art)
    XCTAssertEqual(Category.art.parent, nil)
  }

  func testParentCategoryType() {
    let parent = ParentCategory(
      analyticsName: Category.art.analyticsName,
      id: Category.art.id,
      name: Category.art.name
    )
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
    XCTAssertNil(
      (Category.illustration
        |> Category.lens.parent .~ nil).root,
      "A subcategory with no parent category present does not have a root."
    )
  }

  func testDecodedId() {
    let art = Category.art
      |> Category.lens.id .~ "1"
    XCTAssertEqual(Category.decode(id: art.id), "Category-1")
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
