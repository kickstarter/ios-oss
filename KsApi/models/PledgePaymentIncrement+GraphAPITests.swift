import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class PledgePaymentIncrementGraphAPITests: XCTestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
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

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment!.state, .collected)
    XCTAssertEqual(increment!.stateReason, .requiresAction)
    XCTAssertNil(increment!.refundedAmount)
  }

  func testPaymentIncrementViewModel_fromValidFragment_refundedAmount_isCorrect() {
    let variables = ["includeRefundedAmount": true]

    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"

    mock.refundedAmount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.refundedAmount?.currency = "USD"
    mock.refundedAmount?.amountFormattedInProjectNativeCurrency = "$55.50"

    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.collected)

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock, withVariables: variables)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment?.state, .collected)
    XCTAssertNil(increment?.stateReason)
    XCTAssertNotNil(increment?.refundedAmount)
    XCTAssertEqual(increment?.refundedAmount?.currency, "USD")
    XCTAssertEqual(increment?.refundedAmount?.amountFormattedInProjectNativeCurrency, "$55.50")
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
    let variables = ["includeRefundedAmount": false]

    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()

    mock.scheduledCollection = "not a date :("

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock, withVariables: variables)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)

    XCTAssertNil(increment)
  }
}
