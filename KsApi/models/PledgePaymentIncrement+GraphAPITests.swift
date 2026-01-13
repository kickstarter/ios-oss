import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi
import XCTest

final class PledgePaymentIncrementGraphAPITests: XCTestCase {
  func testPaymentIncrementViewModel_fromValidFragment_isCorrect() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"

    let incrementFragment = GraphAPI.PaymentIncrementFragment.from(mock)
    let increment = PledgePaymentIncrement(withGraphQLFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment!.amount.currency, "USD")
    XCTAssertEqual(increment!.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment!.scheduledCollection, 1_743_431_359.0)
    XCTAssertNil(increment?.badge, "Badge should not be set for PaymentIncrementFragment")
    XCTAssertEqual(
      increment?.refundStatus,
      .unknown,
      "Refund status should not be set for PaymentIncrementFragment"
    )
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

    mock.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    mock.badge?.variant = GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>(.green)
    mock.badge?.copy = "Collected (Adjusted)"

    let incrementFragment = GraphAPI.PaymentIncrementBackingFragment.from(mock)
    let increment = PledgePaymentIncrement(withIncrementBackingFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)

    if case let .partialRefund(amount) = increment?.refundStatus {
      XCTAssertEqual(amount.currency, "USD")
      XCTAssertEqual(amount.amountFormattedInProjectNativeCurrency, "$55.50")
    } else {
      XCTFail("Expected refundStatus to be .refunded")
    }

    XCTAssertNotNil(increment!.badge)
    XCTAssertEqual(increment?.badge?.variant, .green)
    XCTAssertEqual(increment?.badge?.copy, "Collected (Adjusted)")
  }

  func testPaymentIncrementViewModel_fromIncrementBackingFragment_withFullRefunded() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"
    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.refunded)

    mock.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    mock.badge?.variant = GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>(.gray)
    mock.badge?.copy = "Refunded"

    mock.refundedAmount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.refundedAmount?.currency = "USD"
    mock.refundUpdatedAmountInProjectNativeCurrency = "$0.00"

    let incrementFragment = GraphAPI.PaymentIncrementBackingFragment.from(mock)
    let increment = PledgePaymentIncrement(withIncrementBackingFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment?.badge?.copy, "Refunded")
    XCTAssertEqual(increment?.refundStatus, .fullRefund)
  }

  func testPaymentIncrementViewModel_fromIncrementBackingFragment_notRefundedAmount() {
    let mock = Mock<GraphAPITestMocks.PaymentIncrement>()
    mock.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    mock.amount?.currency = "USD"
    mock.amount?.amountFormattedInProjectNativeCurrency = "$99.75"

    mock.scheduledCollection = "2025-03-31T10:29:19-04:00"
    mock.state = GraphQLEnum<PaymentIncrementState>(PaymentIncrementState.collected)

    mock.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    mock.badge?.variant = GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>(.green)
    mock.badge?.copy = "Collected"

    let incrementFragment = GraphAPI.PaymentIncrementBackingFragment.from(mock)
    let increment = PledgePaymentIncrement(withIncrementBackingFragment: incrementFragment)

    XCTAssertNotNil(increment)
    XCTAssertEqual(increment?.amount.currency, "USD")
    XCTAssertEqual(increment?.amount.amountFormattedInProjectNativeCurrency, "$99.75")
    XCTAssertEqual(increment?.scheduledCollection, 1_743_431_359.0)
    XCTAssertEqual(increment?.refundStatus, .notRefunded)

    XCTAssertNotNil(increment!.badge)
    XCTAssertEqual(increment?.badge?.variant, .green)
    XCTAssertEqual(increment?.badge?.copy, "Collected")
  }
}
