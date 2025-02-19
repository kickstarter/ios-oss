import Foundation

extension PledgePaymentIncrement {
  public init?(withGraphQLFragment fragment: GraphAPI.PaymentIncrementFragment) {
    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: fragment.scheduledCollection) else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(
      amountStringValue: fragment.amount.amountAsFloat,
      currency: fragment.amount.currency,
      amountFormattedInProjectNativeCurrency: fragment.amount.amountFormattedInProjectNativeCurrency
    )
    self.scheduledCollection = intervalAsTime
    self.state = PledgePaymentIncrementState(stateValue: fragment.state)

    if let stateReason = fragment.stateReason?.rawValue {
      self.stateReason = PledgePaymentIncrementStateReason(rawValue: stateReason)
    }
  }
}

extension PledgePaymentIncrementState {
  init(stateValue value: GraphAPI.PaymentIncrementState) {
    self = PledgePaymentIncrementState(rawValue: value.rawValue) ?? .unattempted
  }
}
