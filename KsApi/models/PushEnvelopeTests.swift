import XCTest
@testable import KsApi
import Prelude

final class PushEnvelopeTests: XCTestCase {
  func testDecode_Update_WithUpdateKey() {
    let decodedEnvelope = PushEnvelope.decodeJSONDictionary([
      "aps": [
        "alert": "Hi"
      ],
      "update": [
        "id": 1,
        "project_id": 2
      ]
    ])
    let envelope = decodedEnvelope.value

    XCTAssertNil(decodedEnvelope.error)
    XCTAssertNotNil(envelope?.update)
    XCTAssertEqual(1, envelope?.update?.id)
    XCTAssertEqual(2, envelope?.update?.projectId)
  }

  func testDecode_Update_WithPostKey() {
    let decodedEnvelope = PushEnvelope.decodeJSONDictionary([
      "aps": [
        "alert": "Hi"
      ],
      "post": [
        "id": 1,
        "project_id": 2
      ]
      ])
    let envelope = decodedEnvelope.value

    XCTAssertNil(decodedEnvelope.error)
    XCTAssertNotNil(envelope?.update)
    XCTAssertEqual(1, envelope?.update?.id)
    XCTAssertEqual(2, envelope?.update?.projectId)
  }
}
