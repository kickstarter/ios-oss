@testable import KsApi
import XCTest

final class CreateCheckoutEnvelopeTests: XCTestCase {
  func testCreateBackingEnvelopeDecoding() {
    let jsonString = """
    {
      "checkout": {
        "id": "2020",
        "paymentUrl": "https://test-url.com",
        "backingId": "backingId"
      }
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(CreateCheckoutEnvelope.self, from: data)
      XCTAssertEqual(envelope.checkout.id, "2020")
      XCTAssertEqual(envelope.checkout.paymentUrl, "https://test-url.com")
      XCTAssertEqual(envelope.checkout.backingId, "backingId")
    } catch {
      XCTFail("\(error)")
    }
  }
}
