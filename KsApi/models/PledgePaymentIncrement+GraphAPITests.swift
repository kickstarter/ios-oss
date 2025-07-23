import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class PledgePaymentIncrementGraphAPITests: XCTestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
<<<<<<< HEAD
    let variables = ["includeRefundedAmount": false]

    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"

    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.collected)
    mock.stateReason = GraphQLEnum<PaymentIncrementStateReason>(PaymentIncrementStateReason.requiresAction)

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock, withVariables: variables)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)
=======
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
        "stateReason": "REQUIRES_ACTION",
        "refundedAmount": null
      }
    """

    let variables = ["includeRefundedAmount": false]
    let fragment: GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement = try! testGraphObject(jsonString: jsonString, variables: variables)
>>>>>>> 8d3217750 (Fix unit tests)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment!.state, .collected)
    XCTAssertEqual(increment!.stateReason, .requiresAction)
    XCTAssertNil(increment!.refundedAmount)
  }

  func testPaymentIncrementViewModel_fromValidFragment_refundedAmount_isCorrect() {
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
        "stateReason": "REQUIRES_ACTION",
        "refundedAmount": null
      }
    """

    let variables = ["includeRefundedAmount": false]
    let fragment: GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement = try! testGraphObject(jsonString: jsonString, variables: variables)

    let increment = PledgePaymentIncrement(withGraphQLFragment: fragment.fragments.paymentIncrementFragment)
    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment!.state, .collected)
    XCTAssertEqual(increment!.stateReason, .requiresAction)
    XCTAssertNil(increment!.refundedAmount)
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
    let variables = ["includeRefundedAmount": false]

<<<<<<< HEAD
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()

    mock.scheduledCollection = "not a date :("

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock, withVariables: variables)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)
=======
        "scheduledCollection": "not a date :(",
        "state": "COLLECTED",
        "stateReason": "REQUIRES ACTION",
        "refundedAmount": null
      }
    """

    let variables = ["includeRefundedAmount": false]
    let fragment: GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement = try! testGraphObject(jsonString: jsonString, variables: variables)
>>>>>>> 8d3217750 (Fix unit tests)

    XCTAssertNil(increment)
  }
}
