import Foundation
import GraphAPI

extension PledgePaymentIncrement {
  public init?(withGraphQLFragment fragment: GraphAPI.PaymentIncrementFragment) {
    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: fragment.scheduledCollection) else {
      return nil
    }

    guard let stateValue = fragment.state.value else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(
      currency: fragment.amount.currency,
      amountFormattedInProjectNativeCurrency: fragment.amount.amountFormattedInProjectNativeCurrency
    )
    self.scheduledCollection = intervalAsTime

    self.stateBadgeName = fragment.stateBadgeName
    self.stateBadgeStyle = fragment.stateBadgeStyle
  }

  public init?(withIncrementBackingFragment data: PaymentIncrementBackingFragment) {
    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: data.scheduledCollection) else {
      return nil
    }

    guard let stateValue = data.state.value else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(
      currency: data.amount.currency,
      amountFormattedInProjectNativeCurrency: data.amount.amountFormattedInProjectNativeCurrency
    )
    self.scheduledCollection = intervalAsTime

    // If we get a `refundedAmount`, it means this increment was refunded
    // so we store the amount. If not, we treat it as not refunded.
    if let refundedAmountData = data.refundedAmount,
       let formattedRefund = data.refundUpdatedAmountInProjectNativeCurrency {
      let refundedAmount = PledgePaymentIncrementAmount(
        currency: refundedAmountData.currency,
        amountFormattedInProjectNativeCurrency: formattedRefund
      )

      self.amount = refundedAmount
    }

    self.stateBadgeName = data.stateBadgeName
    self.stateBadgeStyle = data.stateBadgeStyle
  }
}
