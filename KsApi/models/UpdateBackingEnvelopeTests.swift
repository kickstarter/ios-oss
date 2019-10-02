@testable import KsApi
import XCTest

final class UpdateBackingEnvelopeTests: XCTestCase {
  func testUpdateBackingEnvelopeDecoding() {
    let jsonString = """
    {
      "updateBacking": {
        "checkout": {
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
      let envelope = try JSONDecoder().decode(UpdateBackingEnvelope.self, from: data)
      XCTAssertEqual(envelope.updateBacking.checkout.state, .verifying)
      XCTAssertEqual(envelope.updateBacking.checkout.backing.requiresAction, false)
      XCTAssertEqual(envelope.updateBacking.checkout.backing.clientSecret, "super-secret")
    } catch {
      XCTFail("\(error)")
    }
  }

  func testUpdateBackingEnvelopeDecoding_NilClientSecret() {
    let jsonString = """
    {
      "updateBacking": {
        "checkout": {
          "state": "VERIFYING",
          "backing": {
            "requiresAction": false,
            "clientSecret": null
          }
        }
      }
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(UpdateBackingEnvelope.self, from: data)
      XCTAssertEqual(envelope.updateBacking.checkout.state, .verifying)
      XCTAssertEqual(envelope.updateBacking.checkout.backing.requiresAction, false)
      XCTAssertEqual(envelope.updateBacking.checkout.backing.clientSecret, nil)
    } catch {
      XCTFail("\(error)")
    }
  }
}
