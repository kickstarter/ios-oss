import Foundation
@testable import KsApi

/// PaymentIncrements may or may not have `refundStatus` and `badge` set,
/// depending on if they were made with a query that explicitly fetches that data or not.
/// (This is for performance reasons on the backend).
/// This method  creates mock payments that come _without_ backing information, with no badge or refund.
public func mockPaymentIncrements()
  -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )
  let scheduledCollection = TimeInterval(1_553_731_200)
  return [
    PledgePaymentIncrement(
      amount: amount,
      refundStatus: .unknown,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      refundStatus: .unknown,
      scheduledCollection: scheduledCollection,
    ),
    PledgePaymentIncrement(
      amount: amount,
      refundStatus: .unknown,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      refundStatus: .unknown,
      scheduledCollection: scheduledCollection
    )
  ]
}

/// PaymentIncrements may or may not have `refundStatus` and `badge` set,
/// depending on if they were made with a query that explicitly fetches that data or not.
/// (This is for performance reasons on the backend).
/// This method  creates mock payments that come _with_ backing information, with a badge and refund.
public func mockPaymentIncrementsForManagingBacking() -> [PledgePaymentIncrement] {
  let amount = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$250.00"
  )
  let amountAfterAdjustment = PledgePaymentIncrementAmount(
    currency: "USD",
    amountFormattedInProjectNativeCurrency: "$55.00"
  )

  let scheduledCollection = TimeInterval(1_553_731_200)

  let increments = [
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Green badge",
        variant: .green
      ),
      refundStatus: .notRefunded,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Purple badge",
        variant: .purple
      ),
      refundStatus: .notRefunded,
      scheduledCollection: scheduledCollection,
    ),
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Gray badge",
        variant: .gray
      ),
      refundStatus: .notRefunded,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Danger badge",
        variant: .danger
      ),
      refundStatus: .notRefunded,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Red badge",
        variant: .red
      ),
      refundStatus: .notRefunded,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Badge with full refund",
        variant: .gray
      ),
      refundStatus: .fullRefund,
      scheduledCollection: scheduledCollection
    ),
    PledgePaymentIncrement(
      amount: amount,
      badge: PledgePaymentIncrement.Badge(
        copy: "Badge with partial refund",
        variant: .purple
      ),
      refundStatus: .partialRefund(amountAfterAdjustment),
      scheduledCollection: scheduledCollection
    )
  ]

  return increments
}
