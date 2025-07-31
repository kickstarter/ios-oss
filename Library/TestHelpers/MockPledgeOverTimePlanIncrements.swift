import Foundation
import KsApi

public func mockPaymentIncrements() -> [PledgePaymentIncrement] {
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
      refundStatus: .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .unattempted,
      stateReason: nil,
      refundStatus: .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .cancelled,
      stateReason: nil,
      refundStatus: .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .errored,
      stateReason: nil,
      refundStatus: .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .errored,
      stateReason: .requiresAction,
      refundStatus: .unknown
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .refunded,
      stateReason: nil,
      refundStatus: .refunded(amount)
    )
  ]
}
