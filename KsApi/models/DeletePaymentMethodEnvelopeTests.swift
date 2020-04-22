@testable import KsApi
import XCTest

class DeletePaymentMethodEnvelopeTests: XCTestCase {
  func testDeletePaymentMethodEnvelopeDecoding() {
    let jsonString = """
    {
      "paymentSourceDelete": {
          "user": {
            "storedCards": {
              "nodes": [
                {
                  "expirationDate": "2055-11-01",
                  "id": "1057",
                  "lastFour": "1111",
                  "type": "VISA"
                },
                {
                  "expirationDate": "2044-04-01",
                  "id": "1055",
                  "lastFour": "4444",
                  "type": "MASTERCARD"
                }
              ]
            }
          }
      }
    }
    """
    let data = jsonString.data(using: .utf8)

    do {
      let envelope = try JSONDecoder().decode(DeletePaymentMethodEnvelope.self, from: data!)
      XCTAssertEqual(envelope.storedCards.first?.expirationDate, "2055-11-01")
      XCTAssertEqual(envelope.storedCards.first?.id, "1057")
      XCTAssertEqual(envelope.storedCards.first?.lastFour, "1111")
      XCTAssertEqual(envelope.storedCards.first?.type, .visa)
      XCTAssertEqual(envelope.storedCards.last?.expirationDate, "2044-04-01")
      XCTAssertEqual(envelope.storedCards.last?.id, "1055")
      XCTAssertEqual(envelope.storedCards.last?.lastFour, "4444")
      XCTAssertEqual(envelope.storedCards.last?.type, .mastercard)
      XCTAssertEqual(envelope.storedCards.count, 2)
    } catch {
      XCTFail("DeletePaymentMethodEnvelope should be decoded!")
    }
  }
}
