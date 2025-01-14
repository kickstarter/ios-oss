@testable import KsApi
import XCTest

final class PledgePaymentIncrementGraphAPITests: XCTestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
    let jsonString = """
      {
        "__typename": "PaymentIncrement",
        "amount": {
          "__typename": "PaymentIncrementAmount",
          "amountAsFloat": "99.75",
          "amountFormattedInProjectNativeCurrency": "$99.75",
          "currency": "USD"
        },
        "scheduledCollection": "2025-03-31T10:29:19-04:00",
        "state": "some state"
      }
    """

    let fragment = try! GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement(jsonString: jsonString)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment.fragments.paymentIncrementFragment)
    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amount, Double(99.75))
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
    let jsonString = """
      {
        "__typename": "PaymentIncrement",
        "amount": {
          "__typename": "PaymentIncrementAmount",
          "amountAsFloat": "99.75",
          "amountFormattedInProjectNativeCurrency": "$99.75",
          "currency": "USD"
        },
    
        "scheduledCollection": "not a date :(",
        "state": "some state"
      }
    """

    let fragment = try! GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement(jsonString: jsonString)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment.fragments.paymentIncrementFragment)
    XCTAssertNil(increment)
  }
}
