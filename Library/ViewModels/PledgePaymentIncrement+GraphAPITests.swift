@testable import KsApi
@testable import Library
import XCTest

final class PledgePaymentIncrementGraphAPITests: TestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
    let jsonString = """
      {
        "__typename": "PaymentIncrement",
        "amount": {
          "__typename": "Money",
          "amount": "99.75",
          "currency": "USD"
        },
        "scheduledCollection": "2025-03-31T10:29:19-04:00",
      }
    """

    let fragment = try! GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement(jsonString: jsonString)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment)
    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amount, Double(99.75))
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
    let jsonString = """
      {
        "__typename": "PaymentIncrement",
        "amount": {
          "__typename": "Money",
          "amount": "99.75",
          "currency": "USD"
        },
        "scheduledCollection": "not a date :(",
      }
    """

    let fragment = try! GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement(jsonString: jsonString)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment)
    XCTAssertNil(increment)
  }
}
