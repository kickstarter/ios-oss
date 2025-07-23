import GraphAPI
@testable import KsApi
import XCTest

class GraphAPI_CreatePaymentSourceInput_CreatePaymentSourceInputTests: XCTestCase {
  func testPaymentSourceInputCreation_WithValidData_Success() {
    let input = CreatePaymentSourceInput(
      paymentType: .creditCard,
      reusable: true,
      stripeToken: "token",
      stripeCardId: "cardToken"
    )

    let graphInput = GraphAPI.CreatePaymentSourceInput.from(input)

    XCTAssertEqual(graphInput.paymentType.unwrapped?.value, .creditCard)
    XCTAssertEqual(graphInput.reusable.unwrapped, input.reusable)
    XCTAssertEqual(graphInput.stripeToken.unwrapped, input.stripeToken)
    XCTAssertEqual(graphInput.stripeCardId.unwrapped, input.stripeCardId)
  }

  func testPaymentSheetPaymentSourceInputCreation_WithValidData_Success() {
    let input = CreatePaymentSourceSetupIntentInput(intentClientSecret: "xyz", reuseable: true)

    let graphInput = GraphAPI.CreatePaymentSourceInput.from(input)

    XCTAssertEqual(graphInput.intentClientSecret.unwrapped, input.intentClientSecret)
    XCTAssertEqual(graphInput.reusable.unwrapped, input.reuseable)
  }
}
