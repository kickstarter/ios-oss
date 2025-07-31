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
      refundedAmount: nil
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .unattempted,
      stateReason: nil,
      refundedAmount: nil
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .cancelled,
      stateReason: nil,
      refundedAmount: nil
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .errored,
      stateReason: nil,
      refundedAmount: nil
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .errored,
      stateReason: .requiresAction,
      refundedAmount: nil
    ),
    PledgePaymentIncrement(
      amount: amount,
      scheduledCollection: scheduledCollection,
      state: .refunded,
      stateReason: nil,
      refundedAmount: nil
    )
  ]
}
