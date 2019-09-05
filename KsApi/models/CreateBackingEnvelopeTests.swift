@testable import KsApi
import XCTest

final class CreateBackingEnvelopeTests: XCTestCase {
  private var json: String {
    return """
    createBacking {
      createBacking(input: {
        projectId: 1622745379,
        amount: "20",
        locationId: "4oCcTG9jYXRpb24tMjQ2OTk0OeKAnQ==",
        rewardId: nil,
        paymentSourceId: "paymentid",
        paymentType: "card"
      })
    }
    """
  }

  func testDecode() {
    if let decodeData = envelopeFromJSON() {
      let checkout = decodeData.createBacking.checkout
      XCTAssertEqual(checkout.state, .verifying)
    }
  }

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

  private func envelopeFromJSON() -> CreateBackingEnvelope? {
    if let jsonData = json.data(using: .utf8) {
      do {
        let decodedData = try JSONDecoder().decode(CreateBackingEnvelope.self, from: jsonData)
        return decodedData
      } catch {
        return nil
      }
    }
    return nil
  }
}
