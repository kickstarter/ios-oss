@testable import KsApi
import XCTest

class GraphAPI_CreatePaymentSourceInput_CreatePaymentSourceInputTests: XCTestCase {
  func testPaymentSourceInputCreation_WithValidData_Success() {
    let input = CreatePaymentSourceInput(paymentType: .creditCard,
                                         reusable: true,
                                         stripeToken: "token",
                                         stripeCardId: "cardToken")

    let graphInput = GraphAPI.CreatePaymentSourceInput.from(input)

    XCTAssertEqual(graphInput.paymentType, .creditCard)
    XCTAssertEqual(graphInput.reusable, input.reusable)
    XCTAssertEqual(graphInput.stripeToken, input.stripeToken)
    XCTAssertEqual(graphInput.stripeCardId, input.stripeCardId)
  }
}
