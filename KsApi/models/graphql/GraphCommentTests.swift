@testable import KsApi
import XCTest

final class GraphCommentTests: XCTestCase {
  func testDecode() {
    let dictionary: [String: Any] =
      [
        "author": [
          "id": "VXNlci0xOTE1MDY0NDY3",
          "isCreator": nil,
          "name": "James Bond"
        ],
        "body": "I have not received a survey yet either.",
        "id": "Q29tbWVudC0zMDQ5MDQ2NA==",
        "replies": [
          "totalCount": 5
        ]
      ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let comment = try? JSONDecoder().decode(GraphComment.self, from: data)

    XCTAssertEqual(comment?.body, "I have not received a survey yet either.")
    XCTAssertEqual(comment?.id, "Q29tbWVudC0zMDQ5MDQ2NA==")
    XCTAssertEqual(comment?.replyCount, 5)
    XCTAssertEqual(comment?.author.id, "VXNlci0xOTE1MDY0NDY3")
    XCTAssertEqual(comment?.author.isCreator, false)
    XCTAssertEqual(comment?.author.name, "James Bond")
  }
}
