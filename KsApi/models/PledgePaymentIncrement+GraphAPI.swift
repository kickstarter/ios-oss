import Foundation

extension PledgePaymentIncrement {
  public init?(withGraphQLFragment fragment: GraphAPI.PaymentIncrementFragment) {
    let moneyFragment = fragment.amount.fragments.moneyFragment
    guard let amountAsString = moneyFragment.amount,
          let amountAsDouble = Double(amountAsString),
          let currency = moneyFragment.currency?.rawValue else {
      return nil
    }

    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: fragment.scheduledCollection) else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(amount: amountAsDouble, currency: currency)
    self.scheduledCollection = intervalAsTime
    self.state = fragment.state
  }
}
