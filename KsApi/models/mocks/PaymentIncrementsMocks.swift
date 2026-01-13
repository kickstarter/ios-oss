import ApolloTestSupport
import GraphAPI
import GraphAPITestMocks
@testable import KsApi

let paymentIncrement = Mock<GraphAPITestMocks.PaymentIncrement>()

extension GraphAPITestMocks.PaymentIncrement {
  static var scheduledMock: Mock<GraphAPITestMocks.PaymentIncrement> {
    let paymentIncrement = Mock<GraphAPITestMocks.PaymentIncrement>()

    paymentIncrement.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    paymentIncrement.amount?.amountFormattedInProjectNativeCurrency = "$43.00"
    paymentIncrement.amount?.currency = "USD"
    paymentIncrement.scheduledCollection = "2025-07-30T03:31:43Z"
    paymentIncrement.state = .case(.unattempted)
    paymentIncrement.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    paymentIncrement.badge?.variant = GraphQLEnum.case(.purple)
    paymentIncrement.badge?.copy = "Scheduled"

    return paymentIncrement
  }

  static var collectedMock: Mock<GraphAPITestMocks.PaymentIncrement> {
    let paymentIncrement = Mock<GraphAPITestMocks.PaymentIncrement>()

    paymentIncrement.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    paymentIncrement.amount?.amountFormattedInProjectNativeCurrency = "$43.00"
    paymentIncrement.amount?.currency = "USD"
    paymentIncrement.scheduledCollection = "2025-07-30T03:31:43Z"
    paymentIncrement.state = .case(.collected)
    paymentIncrement.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    paymentIncrement.badge?.variant = GraphQLEnum.case(.green)
    paymentIncrement.badge?.copy = "Collected"

    return paymentIncrement
  }

  static var collectedAdjustedMock: Mock<GraphAPITestMocks.PaymentIncrement> {
    let paymentIncrement = Mock<GraphAPITestMocks.PaymentIncrement>()

    paymentIncrement.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    paymentIncrement.amount?.amountFormattedInProjectNativeCurrency = "$43.00"
    paymentIncrement.amount?.currency = "USD"
    paymentIncrement.scheduledCollection = "2025-07-30T03:31:43Z"
    paymentIncrement.state = .case(.collectedAdjusted)
    paymentIncrement.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    paymentIncrement.badge?.variant = GraphQLEnum.case(.green)
    paymentIncrement.badge?.copy = "Collected (adjusted)"

    paymentIncrement.refundedAmount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    paymentIncrement.refundedAmount?.amountFormattedInProjectNativeCurrency = "$20.00"
    paymentIncrement.refundedAmount?.currency = "USD"

    paymentIncrement.refundUpdatedAmountInProjectNativeCurrency = "$23.00"

    return paymentIncrement
  }

  static var refundedMock: Mock<GraphAPITestMocks.PaymentIncrement> {
    let paymentIncrement = Mock<GraphAPITestMocks.PaymentIncrement>()

    paymentIncrement.amount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    paymentIncrement.amount?.amountFormattedInProjectNativeCurrency = "$43.00"
    paymentIncrement.amount?.currency = "USD"
    paymentIncrement.scheduledCollection = "2025-07-30T03:31:43Z"
    paymentIncrement.state = .case(.refunded)
    paymentIncrement.badge = Mock<GraphAPITestMocks.PaymentIncrementBadge>()
    paymentIncrement.badge?.variant = GraphQLEnum.case(.gray)
    paymentIncrement.badge?.copy = "Refunded"

    paymentIncrement.refundedAmount = Mock<GraphAPITestMocks.PaymentIncrementAmount>()
    paymentIncrement.refundedAmount?.amountFormattedInProjectNativeCurrency = "$43.00"
    paymentIncrement.refundedAmount?.currency = "USD"

    paymentIncrement.refundUpdatedAmountInProjectNativeCurrency = "$0.00"

    return paymentIncrement
  }
}
