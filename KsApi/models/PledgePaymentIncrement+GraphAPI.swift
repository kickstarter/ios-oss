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
  }
}

extension PledgePaymentIncrementState {
  init(stateValue value: String) {
    self = PledgePaymentIncrementState(rawValue: value) ?? .unattempted
  }
}
