import XCTest
@testable import KsApi
@testable import Argo

final class CheckoutEnvelopeTests: XCTestCase {
  func testJsonDecoding() {
    let json: [String: Any] = [
      "state": "failed",
      "state_reason": "Oof!"
    ]

    let envelope = CheckoutEnvelope.decodeJSONDictionary(json)

    XCTAssertEqual(CheckoutEnvelope.State.failed, envelope.value?.state)
    XCTAssertEqual("Oof!", envelope.value?.stateReason)
  }
}
