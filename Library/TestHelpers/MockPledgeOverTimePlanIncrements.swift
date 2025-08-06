import Foundation
import KsApi

public func mockPaymentIncrements(withRefunds includeRefunds: Bool = false) -> [PledgePaymentIncrement] {
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

public func mockPaymentIncrementsWithRefundedItems() -> [PledgePaymentIncrement] {
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

  return mockPaymentIncrements(withRefunds: true) + [collectedAdjustedIncrement, refundedIncrement]
}
