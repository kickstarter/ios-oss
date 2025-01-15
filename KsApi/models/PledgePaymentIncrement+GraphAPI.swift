import Foundation

extension PledgePaymentIncrement {
  public init?(withGraphQLFragment fragment: GraphAPI.PaymentIncrementFragment) {
    let amountAsString = fragment.amount.amountAsFloat
    guard let amountAsDouble = Double(amountAsString) else {
      return nil
    }

    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: fragment.scheduledCollection) else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(
      amount: amountAsDouble,
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
