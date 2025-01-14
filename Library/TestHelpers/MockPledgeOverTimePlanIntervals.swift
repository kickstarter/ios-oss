import Foundation
import KsApi

public func mockPaymentIncrements() -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(
    amount: 250.0,
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )
  let scheduledCollection = TimeInterval(1_553_731_200)
  return [
    PledgePaymentIncrement(amount: amount, scheduledCollection: scheduledCollection, state: .collected),
    PledgePaymentIncrement(amount: amount, scheduledCollection: scheduledCollection, state: .errored),
    PledgePaymentIncrement(amount: amount, scheduledCollection: scheduledCollection, state: .unattempted),
    PledgePaymentIncrement(amount: amount, scheduledCollection: scheduledCollection, state: .unattempted)
  ]
}
