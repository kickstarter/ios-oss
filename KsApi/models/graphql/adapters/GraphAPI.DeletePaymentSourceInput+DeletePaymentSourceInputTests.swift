@testable import KsApi
import XCTest

class GraphAPI_DeletePaymentSourceInput_DeletePaymentSourceInputTests: XCTestCase {
  func testDeletePaymentSourceInputCreation_WithValidData_Success() {
    let input = PaymentSourceDeleteInput(paymentSourceId: "69021330")

    let graphInput = GraphAPI.PaymentSourceDeleteInput.from(input)

    XCTAssertEqual(graphInput.paymentSourceId, "69021330")
  }
}
