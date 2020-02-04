@testable import KsApi
import XCTest

final class CreateBackingEnvelopeTests: XCTestCase {
  func testCreateBackingEnvelopeDecoding() {
    let jsonString = """
    {
      "createBacking": {
        "checkout": {
          "id": "2020",
          "state": "VERIFYING",
          "backing": {
            "requiresAction": false,
            "clientSecret": "super-secret"
          }
        }
      }
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(CreateBackingEnvelope.self, from: data)
      XCTAssertEqual(envelope.createBacking.checkout.id, "2020")
      XCTAssertEqual(envelope.createBacking.checkout.state, .verifying)
      XCTAssertEqual(envelope.createBacking.checkout.backing.requiresAction, false)
      XCTAssertEqual(envelope.createBacking.checkout.backing.clientSecret, "super-secret")
    } catch {
      XCTFail("\(error)")
    }
  }
}
