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

    if let refundedAmount = fragment.refundedAmount {
      self.refundedAmount = PledgePaymentIncrementAmount(
        currency: refundedAmount.currency,
        amountFormattedInProjectNativeCurrency: refundedAmount.amountFormattedInProjectNativeCurrency
      )
    } else {
      self.refundedAmount = nil
    }
  }
}

extension PledgePaymentIncrementState {
  init(stateValue value: GraphAPI.PaymentIncrementState) {
    self = PledgePaymentIncrementState(rawValue: value.rawValue) ?? .unattempted
  }
}
