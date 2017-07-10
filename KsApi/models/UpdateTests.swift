import XCTest
@testable import KsApi
import Argo
import Prelude

final internal class UpdateTests: XCTestCase {

  func testEquatable() {
    XCTAssertEqual(Update.template, Update.template)
    XCTAssertNotEqual(Update.template, Update.template |> Update.lens.id %~ { $0 + 1 })
  }

  func testJSONDecoding_WithBadData() {
    let update = Update.decodeJSONDictionary([
      "body": "world",
      ])

    XCTAssertNotNil(update.error)
  }

  func testJSONDecoding_WithGoodData() {
    let update = Update.decodeJSONDictionary([
      "body": "world",
      "id": 1,
      "public": true,
      "project_id": 2,
      "sequence": 3,
      "title": "hello",
      "visible": true,
      "urls": [
        "web": [
          "update": "https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540"
        ]
      ]
      ])

    XCTAssertNil(update.error)
    XCTAssertEqual(1, update.value?.id)
  }

  func testJSONDecoding_WithNestedGoodData() {
    let update = Update.decodeJSONDictionary([
      "body": "world",
      "id": 1,
      "public": true,
      "project_id": 2,
      "sequence": 3,
      "title": "hello",
      "user": [
        "id": 2,
        "name": "User",
        "avatar": [
          "medium": "img.jpg",
          "small": "img.jpg",
          "large": "img.jpg",
        ]
      ],
      "visible": true,
      "urls": [
        "web": [
          "update": "https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540"
        ]
      ]
      ])

    XCTAssertNil(update.error)
    XCTAssertEqual(1, update.value?.id)
    XCTAssertEqual(2, update.value?.user?.id)
    XCTAssertEqual("https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540",
                   update.value?.urls.web.update)
  }
}
