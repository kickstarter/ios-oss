import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
@testable import KsApiTestHelpers
import XCTest

final class PledgePaymentIncrementGraphAPITests: XCTestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"

    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.collected)
    mock.stateReason = GraphQLEnum<PaymentIncrementStateReason>(PaymentIncrementStateReason.requiresAction)

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment!.state, .collected)
    XCTAssertEqual(increment!.stateReason, .requiresAction)
    XCTAssertEqual(increment!.refundStatus, .unknown)
  }

  func testPaymentIncrementViewModel_fromInvalidFragment_isNil() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()

    mock.scheduledCollection = "not a date :("

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)

    XCTAssertNil(increment)
  }

  func testPaymentIncrementViewModel_fromIncrementBackingFragment_withPartialRefundedAmount() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"
    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.collected)

    mock.refundedAmount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.refundedAmount?.currency = "USD"
    mock.refundUpdatedAmountInProjectNativeCurrency = "$55.50"

    let incrementFragment = GraphAPI.PaymentIncrementBackingFragment.from(mock)
    let increment = PledgePaymentIncrement(withIncrementBackingFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment?.state, .collected)
    XCTAssertNil(increment?.stateReason)

    if case let .partialRefund(amount) = increment?.refundStatus {
      XCTAssertEqual(amount.currency, "USD")
      XCTAssertEqual(amount.amountFormattedInProjectNativeCurrency, "$55.50")
    } else {
      XCTFail("Expected refundStatus to be .refunded")
    }
  }

  func testPaymentIncrementViewModel_fromIncrementBackingFragment_withFullRefunded() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"
    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.refunded)

    mock.refundedAmount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.refundedAmount?.currency = "USD"
    mock.refundUpdatedAmountInProjectNativeCurrency = "$0.00"

    let incrementFragment = GraphAPI.PaymentIncrementBackingFragment.from(mock)
    let increment = PledgePaymentIncrement(withIncrementBackingFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment?.state, .refunded)
    XCTAssertNil(increment?.stateReason)
    XCTAssertEqual(increment?.refundStatus, .fullRefund)
  }

  func testPaymentIncrementViewModel_fromIncrementBackingFragment_notRefundedAmount() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"
    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.collected)

    let incrementFragment = GraphAPI.PaymentIncrementBackingFragment.from(mock)
    let increment = PledgePaymentIncrement(withIncrementBackingFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment?.state, .collected)
    XCTAssertNil(increment?.stateReason)
    XCTAssertEqual(increment?.refundStatus, .notRefunded)
  }
}
