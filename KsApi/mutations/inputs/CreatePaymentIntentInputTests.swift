@testable import KsApi
import Prelude
import XCTest

final class CreatePaymentIntentInputTests: XCTestCase {
  func testCreateCheckoutInputDictionary() {
    let createCheckoutInput = CreatePaymentIntentInput(
      projectId: "projectId",
      backingId: "backingId",
      amountDollars: "200.00",
      checkoutId: "checkoutId",
      digitalMarketingAttributed: false
    )

    let input = createCheckoutInput.toInputDictionary()

    XCTAssertEqual(input["projectId"] as? String, "projectId")
    XCTAssertEqual(input["backingId"] as? String, "backingId")
    XCTAssertEqual(input["amountDollars"] as? String, "200.00")
    XCTAssertEqual(input["digitalMarketingAttributed"] as? Bool, false)
    XCTAssertEqual(input["checkoutId"] as? String, "checkoutId")
  }
}
