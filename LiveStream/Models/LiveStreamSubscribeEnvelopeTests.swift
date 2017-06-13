import XCTest
import Argo
@testable import LiveStream

final class LiveStreamSubscribeEnvelopeTests: XCTestCase {
  func testParseJson_Success() {
    let json: [String:Any] = [
      "success": true
    ]

    let eventsEnvelope = LiveStreamSubscribeEnvelope.decodeJSONDictionary(json)

    XCTAssertNil(eventsEnvelope.error)
    XCTAssertEqual(true, eventsEnvelope.value?.success)
  }

  func testParseJson_Failure() {
    let json: [String:Any] = [
      "success": false,
      "reason": "A great reason"
    ]

    let eventsEnvelope = LiveStreamSubscribeEnvelope.decodeJSONDictionary(json)

    XCTAssertNil(eventsEnvelope.error)
    XCTAssertEqual(false, eventsEnvelope.value?.success)
    XCTAssertEqual("A great reason", eventsEnvelope.value?.reason)
  }
}
