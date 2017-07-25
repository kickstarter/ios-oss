import XCTest
@testable import KsApi
import Argo
import Prelude

class CategoryTests: XCTestCase {

  func testParent() {
    XCTAssertEqual(Category.illustration.parent, Category.art)
    XCTAssertEqual(Category.art.parent, nil)
  }

  func testRoot() {
    XCTAssertEqual(Category.illustration.root, Category.art)
    XCTAssertEqual(Category.illustration.isRoot, false)
    XCTAssertEqual(Category.art.root, Category.art)
    XCTAssertEqual(Category.art.isRoot, true)
    XCTAssertNil((Category.illustration |> Category.lens.parent .~ nil).root,
                 "A subcategory with no parent category present does not have a root.")
  }

  func testEquatable() {
    XCTAssertEqual(Category.art, Category.art)
    XCTAssertNotEqual(Category.art, Category.illustration)
  }

  func testComparable() {
    let categories = [
      Category.illustration,
      Category.documentary,
      Category.filmAndVideo,
      Category.art
      ]

    let sorted = [
      Category.art,
      Category.illustration,
      Category.filmAndVideo,
      Category.documentary,
      ]

    XCTAssertEqual(sorted, categories.sorted())
  }

  func testDescription() {
    XCTAssertNotEqual(Category.art.description, "")
    XCTAssertNotEqual(Category.art.debugDescription, "")
  }

  func testJSONParsing_WithPartialData() {
    let c1 = Category.decodeJSONDictionary([
      "id": 1
      ])
    XCTAssertNotNil(c1.error)

    let c2 = Category.decodeJSONDictionary([
      "id": 1,
      "name": "Art"
      ])
    XCTAssertNotNil(c2.error)

    let c3 = Category.decodeJSONDictionary([
      "id": 1,
      "name": "Art",
      "slug": "art"
      ])
    XCTAssertNotNil(c3.error)
  }

  func testJSONParsing_WithFullData() {

    let c4 = Category.decodeJSONDictionary([
      "id": 1,
      "name": "Art",
      "slug": "art",
      "position": 1
      ])
    XCTAssertNil(c4.error)
    XCTAssertEqual(c4.value?.id, 1)
    XCTAssertEqual(c4.value?.name, "Art")
    XCTAssertEqual(c4.value?.slug, "art")
    XCTAssertEqual(c4.value?.position, 1)

    let c5 = Category.decodeJSONDictionary([
      "id": 22,
      "name": "Illustration",
      "slug": "art/illustration",
      "position": 4,
      "projects_count": 44,
      "parent": [
        "id": 1,
        "name": "Art",
        "slug": "art",
        "position": 1
      ]
      ])
    XCTAssertNil(c5.error)
    XCTAssertEqual(c5.value?.id, 22)
    XCTAssertEqual(c5.value?.name, "Illustration")
    XCTAssertNotEqual(c5.value?.parent, nil)
    XCTAssertEqual(c5.value?.parent?.name, "Art")
    XCTAssertEqual(c5.value?.isRoot, false)
    XCTAssertEqual(c5.value?.root, c5.value?.parent)
    XCTAssertEqual(1, c5.value?.rootId)
    XCTAssertEqual(c5.value?.projectsCount, 44)
  }

  func testJSONParsing_WithPartialParentData() {

    let c6 = Category.decodeJSONDictionary([
      "id": 22,
      "name": "Illustration",
      "slug": "art/illustration",
      "position": 4
      ])
    XCTAssertNil(c6.error)
    XCTAssertEqual(c6.value?.id, 22)
    XCTAssertEqual(c6.value?.name, "Illustration")
    XCTAssertEqual(c6.value?.parent, nil)
  }
}
