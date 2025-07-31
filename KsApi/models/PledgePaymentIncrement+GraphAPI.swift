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
    self.state = PledgePaymentIncrementState(stateValue: stateValue)

    if let stateReason = fragment.stateReason?.rawValue {
      self.stateReason = PledgePaymentIncrementStateReason(rawValue: stateReason)
    }

    // Set `refundStatus` to `.unknown` because the refunded field is not available in this fragment
    self.refundStatus = .unknown
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
    self.state = PledgePaymentIncrementState(stateValue: stateValue)

    if let stateReason = data.stateReason?.rawValue {
      self.stateReason = PledgePaymentIncrementStateReason(rawValue: stateReason)
    }

    // If we get a `refundedAmount`, it means this increment was refunded
    // so we store the amount. If not, we treat it as not refunded.
    if let refundedAmountData = data.refundedAmount {
      let refundedAmount = PledgePaymentIncrementAmount(
        currency: refundedAmountData.currency,
        amountFormattedInProjectNativeCurrency: refundedAmountData.amountFormattedInProjectNativeCurrency
      )

      self.refundStatus = .refunded(refundedAmount)
    } else {
      self.refundStatus = .notRefunded
    }
  }
}

extension PledgePaymentIncrementState {
  init(stateValue value: GraphAPI.PaymentIncrementState) {
    self = PledgePaymentIncrementState(rawValue: value.rawValue) ?? .unattempted
  }
}
