@testable import KsApi
import XCTest

final class PostCommentInputTests: XCTestCase {
  func testInput() {
    let input = PostCommentInput(
      body: "Hello World",
      commentableId: "A8S9DU98asdaQsaf6s=",
      parentId: "a980SDH9a7gdADASD=="
    )

    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["body"] as? String, "Hello World")
    XCTAssertEqual(inputDictionary["commentableId"] as? String, "A8S9DU98asdaQsaf6s=")
    XCTAssertEqual(inputDictionary["parentId"] as? String, "a980SDH9a7gdADASD==")
  }

  func testInput_ParentID_nil() {
    let input = PostCommentInput(body: "Hello World", commentableId: "A8S9DU98asdaQsaf6s=")
    let inputDictionary = input.toInputDictionary()

    XCTAssertEqual(inputDictionary["body"] as? String, "Hello World")
    XCTAssertEqual(inputDictionary["commentableId"] as? String, "A8S9DU98asdaQsaf6s=")
    XCTAssertNil(inputDictionary["parentId"] as? String)
  }
}
