@testable import KsApi
import XCTest

class GraphAPI_CreatePaymentIntentInput_CreatePaymentIntentInputTests: XCTestCase {
  func testCreatePaymentIntentInputCreation_WithValidData_Success() {
    let input = CreatePaymentIntentInput(
      projectId: "projectId",
      amountDollars: "200.00",
      digitalMarketingAttributed: true
    )

    let graphInput = GraphAPI.CreatePaymentIntentInput.from(input)

    XCTAssertEqual(graphInput.projectId, "projectId")
    XCTAssertEqual(graphInput.amountDollars, "200.00")
    XCTAssertEqual(graphInput.digitalMarketingAttributed, true)
  }
}
