import Foundation
import KsApi

public func mockPaymentIncrements() -> [PledgePaymentIncrement] {
  mockPaymentIncrements(includeRefundStatus: false)
}

/// PaymentIncrements may or may not have refundStatus set, depending on if they were made with a query
/// that explicitly fetches refunds or not. (This is for performance reasons on the backend).
/// This method can create mock payment increments as if they came from either kind of query.
private func mockPaymentIncrements(includeRefundStatus includeRefunds: Bool = false)
  -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )
  let scheduledCollection = TimeInterval(1_553_731_200)
  return [
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .collected,
      stateReason: nil,
      refundStatus: includeRefunds ? .notRefunded : .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .unattempted,
      stateReason: nil,
      refundStatus: includeRefunds ? .notRefunded : .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .cancelled,
      stateReason: nil,
      refundStatus: includeRefunds ? .notRefunded : .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .errored,
      stateReason: nil,
      refundStatus: includeRefunds ? .notRefunded : .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .errored,
      stateReason: .requiresAction,
      refundStatus: includeRefunds ? .notRefunded : .unknown
    )
  ]
}

/// This includes an adjusted and a refunded payment increment
public func mockPaymentIncrementsForManagingBacking() -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )
  let scheduledCollection = TimeInterval(1_553_731_200)

  let amountAfterAdjustment = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$55.00"
  )

  let collectedAdjustedIncrement = PledgePaymentIncrement(
    amount: amount,
    scheduledCollection: scheduledCollection,
    state: .collected,
    stateReason: nil,
    refundStatus: .refunded(amountAfterAdjustment)
  )

  let amountAfterFullRefund = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$0.00"
  )

  let refundedIncrement = PledgePaymentIncrement(
    amount: amount,
    scheduledCollection: scheduledCollection,
    state: .refunded,
    stateReason: nil,
    refundStatus: .refunded(amountAfterFullRefund)
  )

  return mockPaymentIncrements(includeRefundStatus: true) + [collectedAdjustedIncrement, refundedIncrement]
}
