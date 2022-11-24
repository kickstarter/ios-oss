@testable import KsApi
import Prelude
import XCTest

internal final class UpdateTests: XCTestCase {
  func testEquatable() {
    XCTAssertEqual(Update.template, Update.template)
    XCTAssertNotEqual(Update.template, Update.template |> Update.lens.id %~ { $0 + 1 })
  }

  func testJSONDecoding_WithBadData() {
    let update: Update! = Update.decodeJSONDictionary([
      "body": "world"
    ])

    XCTAssertNil(update)
  }

  func testJSONDecoding_WithGoodData() {
    let update: Update! = Update.decodeJSONDictionary([
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

    XCTAssertEqual(1, update.id)
  }

  func testJSONDecoding_WithNestedGoodData() {
    let update: Update! = Update.decodeJSONDictionary([
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
          "large": "img.jpg"
        ],
        "needs_password": false
      ],
      "visible": true,
      "urls": [
        "web": [
          "update": "https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540"
        ]
      ]
    ])

    XCTAssertNotNil(update)
    XCTAssertEqual(1, update.id)
    XCTAssertEqual(2, update.user?.id)
    XCTAssertEqual(
      "https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540",
      update.urls.web.update
    )
  }

  func testJSONDecoding_WithBadUrls_WebData_WrongType() {
    let update: Update! = Update.decodeJSONDictionary([
      "body": "world",
      "id": 1,
      "public": true,
      "project_id": 2,
      "sequence": 3,
      "title": "hello",
      "visible": true,
      "urls": [
        "web": [
          "update": 0xBAAAAAAD
        ]
      ]
    ])

    XCTAssertNil(update)
  }

  func testJSONDecoding_WithBadUrls_WebData_WrongKey() {
    let update: Update! = Update.decodeJSONDictionary([
      "body": "world",
      "id": 1,
      "public": true,
      "project_id": 2,
      "sequence": 3,
      "title": "hello",
      "visible": true,
      "urls": [
        "wrong_key": "data"
      ]
    ])

    XCTAssertNil(update)
  }
}
