@testable import KsApi
import XCTest

final class BuildPaymentPlanEnvelopeTestsTests: XCTestCase {
  func testBuildPaymentPlanEnvelopeTestsDecoding() {
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
          "scheduledCollection": "1234567"
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
      XCTAssertEqual(envelope.paymentIncrements.first?.amount.amount, "150.0")
      XCTAssertEqual(envelope.paymentIncrements.first?.amount.currency, "USD")
      XCTAssertEqual(envelope.paymentIncrements.first?.scheduledCollection, "1234567")
    } catch {
      XCTFail("\(error)")
    }
  }
}
