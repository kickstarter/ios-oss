@testable import KsApi
import Prelude
import XCTest

final class CreatePaymentIntentInputTests: XCTestCase {
  func testCreateCheckoutInputDictionary() {
    let createCheckoutInput = CreatePaymentIntentInput(
      projectId: "projectId",
      amountDollars: "200.00",
      digitalMarketingAttributed: false
    )

    let input = createCheckoutInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["amountDollars"] as? String, "200.00")
    XCTAssertEqual(input["digitalMarketingAttributed"] as? Bool, false)
  }
}
