import Foundation
import GraphAPI

extension PledgePaymentIncrement {
  public init?(withGraphQLFragment fragment: GraphAPI.PaymentIncrementFragment) {
    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: fragment.scheduledCollection) else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(
      currency: fragment.amount.currency,
      amountFormattedInProjectNativeCurrency: fragment.amount.amountFormattedInProjectNativeCurrency
    )

    self.scheduledCollection = intervalAsTime
    // Set `refundStatus` to `.unknown` because the refunded field is not available in this fragment
    self.refundStatus = .unknown
  }

  public init?(withIncrementBackingFragment data: PaymentIncrementBackingFragment) {
    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: data.scheduledCollection),
          let stateValue = data.state.value
    else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(
      currency: data.amount.currency,
      amountFormattedInProjectNativeCurrency: data.amount.amountFormattedInProjectNativeCurrency
    )

    if let badge = data.badge {
      self.badge = Badge(from: badge)
    }

    self.scheduledCollection = intervalAsTime

    // If we get a `refundedAmount`, it means this increment was refunded.
    if let refundedAmountData = data.refundedAmount,
       let formattedRefund = data.refundUpdatedAmountInProjectNativeCurrency {
      // If the increment state is REFUNDED, it was a full refund.
      // Otherwise, it was an adjustment of some kind.
      if stateValue == .refunded {
        self.refundStatus = .fullRefund
      } else {
        let refundedAmount = PledgePaymentIncrementAmount(
          currency: refundedAmountData.currency,
          amountFormattedInProjectNativeCurrency: formattedRefund
        )

        self.refundStatus = .partialRefund(refundedAmount)
      }

    } else {
      self.refundStatus = .notRefunded
    }
  }
}

extension PledgePaymentIncrement.Badge.Variant {
  init(from value: GraphQLEnum<GraphAPI.PaymentIncrementBadgeVariant>) {
    self = PledgePaymentIncrement.Badge.Variant(rawValue: value.rawValue) ?? .gray
  }
}

extension PledgePaymentIncrement.Badge {
  init(from badge: GraphAPI.PaymentIncrementBackingFragment.Badge) {
    self = PledgePaymentIncrement.Badge(
      copy: badge.copy,
      variant: PledgePaymentIncrement.Badge.Variant(from: badge.variant)
    )
  }
}
