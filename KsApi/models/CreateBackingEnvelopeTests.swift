@testable import KsApi
import XCTest

final class CreateBackingEnvelopeTests: XCTestCase {

  func testCreateBackingEnvelopeDecoding() {
    let jsonString =
    """
      {
        "createBacking": {
          "checkout": {
              "state": "VERIFYING"
          }
        }
      }
    """

    let data = jsonString.data(using: .utf8)

    do {
      let envelope = try JSONDecoder().decode(CreateBackingEnvelope.self, from: data!)
      XCTAssertEqual(envelope.createBacking.checkout.state, .verifying)
    } catch {
      XCTFail("CreateBackingEnvelope should be decoded!")
    }
  }
}
