@testable import KsApi
import XCTest

final class GraphMutationPostCommentResponseEnvelopeTests: XCTestCase {
  func testDecode() {
    let dictionary: [String: Any] = [
      "createComment": [
        "comment": [
          "body": "Hello World",
          "id": "Q29tbWVudC0zMjY2MjU0MQ=="
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    do {
      let envelope = try JSONDecoder().decode(GraphMutationPostCommentResponseEnvelope.self, from: data)
      XCTAssertEqual(envelope.createComment.comment.body, "Hello World")
      XCTAssertEqual(envelope.createComment.comment.id, "Q29tbWVudC0zMjY2MjU0MQ==")
    } catch {
      XCTFail()
      print(error)
    }
  }
}
