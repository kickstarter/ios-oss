@testable import KsApi
import XCTest

final class GraphMutationPostCommentEnvelopeTests: XCTestCase {
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
      let envelope = try JSONDecoder().decode(GraphMutationPostCommentEnvelope.self, from: data)
      XCTAssertEqual(envelope.body, "Hello World")
      XCTAssertEqual(envelope.id, "Q29tbWVudC0zMjY2MjU0MQ==")
    } catch {
      XCTFail()
      print(error)
    }
  }
}
