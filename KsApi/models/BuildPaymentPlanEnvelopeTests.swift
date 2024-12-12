@testable import KsApi
import XCTest

final class BuildPaymentPlanEnvelopeTestsTests: XCTestCase {
  func testBuildPaymentPlanEnvelopeDecoding() {
    let jsonString = """
    {
      "projectIsPledgeOverTimeAllowed": true,
      "amountIsPledgeOverTimeEligible": true,
      "paymentIncrements": [
        {
          "amount": {
            "amount": "150.0",
            "currency": "USD"
          },
          "id": "1",
          "paymentIncrementableId": "2",
          "paymentIncrementableType": "type",
          "scheduledCollection": "1740174095",
          "state": "unattempted",
          "stateReason": null
        }
      ]
    }
    """

    let data = Data(jsonString.utf8)

    do {
      let envelope = try JSONDecoder().decode(BuildPaymentPlanEnvelope.self, from: data)
      XCTAssertEqual(envelope.projectIsPledgeOverTimeAllowed, true)
      XCTAssertEqual(envelope.amountIsPledgeOverTimeEligible, true)
      XCTAssertEqual(envelope.paymentIncrements.count, 1)
      XCTAssertEqual(envelope.paymentIncrements.first?.id, "1")
      XCTAssertEqual(envelope.paymentIncrements.first?.paymentIncrementableId, "2")
      XCTAssertEqual(envelope.paymentIncrements.first?.paymentIncrementableType, "type")
      XCTAssertEqual(envelope.paymentIncrements.first?.scheduledCollection, "1740174095")
      XCTAssertEqual(envelope.paymentIncrements.first?.state, "unattempted")
      XCTAssertEqual(envelope.paymentIncrements.first?.stateReason, nil)
      XCTAssertEqual(envelope.paymentIncrements.first?.amount.amount, "150.0")
      XCTAssertEqual(envelope.paymentIncrements.first?.amount.currency, "USD")
    } catch {
      XCTFail("\(error)")
    }
  }
}
