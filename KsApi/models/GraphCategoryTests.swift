import XCTest
@testable import KsApi
import Argo
import Prelude

class CategoryTests: XCTestCase {

  func testParent() {
    XCTAssertEqual(RootCategoriesEnvelope.Category.illustration._parent, RootCategoriesEnvelope.Category.art)
    XCTAssertEqual(RootCategoriesEnvelope.Category.art._parent, nil)
  }

  func testParentCategoryType() {
    let parent = ParentCategory(id: RootCategoriesEnvelope.Category.art.id,
                                name: RootCategoriesEnvelope.Category.art.name)
    XCTAssertEqual(parent.categoryType, RootCategoriesEnvelope.Category.illustration._parent)
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
}
