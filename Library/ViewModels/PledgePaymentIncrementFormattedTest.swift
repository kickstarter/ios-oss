import Foundation
@testable import KsApi
@testable import Library
import XCTest

final class PledgePaymentIncrementFormattedTest: TestCase {
  func testIncrementFormat() {
    let amount = PledgePaymentIncrementAmount(
      amount: 20,
      currency: "USD",
      amountFormattedInProjectNativeCurrency: "$20.00"
    )

    let increment = PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: TimeInterval(1_240_902_000),
      state: .collected,
      stateReason: nil
    )

    let incrementFormatted = PledgePaymentIncrementFormatted(from: increment, index: 0)
    XCTAssertEqual(incrementFormatted.incrementChargeNumber, "Charge 1")
    XCTAssertEqual(incrementFormatted.scheduledCollection, "Apr 28, 2009")
    XCTAssertEqual(incrementFormatted.amount, "$20.00")
  }
}
