@testable import KsApi
import XCTest

final class PledgePaymentIncrementGraphAPITests: XCTestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
    let jsonString = """
      {
        "__typename": "PaymentIncrement",
        "amount": {
          "__typename": "PaymentIncrementAmount",
          "amountFormattedInProjectNativeCurrency": "$99.75",
          "currency": "USD"
        },
        "scheduledCollection": "2025-03-31T10:29:19-04:00",
        "state": "COLLECTED",
        "stateReason": "REQUIRES_ACTION"
      }
    """

    let fragment = try! GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement(jsonString: jsonString)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment.fragments.paymentIncrementFragment)
    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment!.state, .collected)
    XCTAssertEqual(increment!.stateReason, .requiresAction)
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
    let jsonString = """
      {
        "__typename": "PaymentIncrement",
        "amount": {
          "__typename": "PaymentIncrementAmount",
          "amountFormattedInProjectNativeCurrency": "$99.75",
          "currency": "USD"
        },

        "scheduledCollection": "not a date :(",
        "state": "COLLECTED",
        "stateReason": "REQUIRES ACTION"
      }
    """

    let fragment = try! GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement(jsonString: jsonString)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment.fragments.paymentIncrementFragment)
    XCTAssertNil(increment)
  }
}
