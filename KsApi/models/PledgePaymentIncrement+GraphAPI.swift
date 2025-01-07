import Foundation

extension PledgePaymentIncrement {
  public init?(
    withGraphQLFragment fragment: GraphAPI.BuildPaymentPlanQuery.Data.Project.PaymentPlan
      .PaymentIncrement
  ) {
    guard let amountAsString = fragment.amount.amount,
          let amountAsDouble = Double(amountAsString),
          let currency = fragment.amount.currency?.rawValue else {
      return nil
    }

    guard let intervalAsTime = TimeInterval.from(ISO8601DateTimeString: fragment.scheduledCollection) else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(amount: amountAsDouble, currency: currency)
    self.scheduledCollection = intervalAsTime
    self.state = fragment.state
  }

  public init?(withGraphQLBackingFragment backingFragment: GraphAPI.BackingFragment.PaymentIncrement) {
    let paymentIncrementFragment = backingFragment.fragments.paymentIncrementFragment

    guard let amountAsString = paymentIncrementFragment.amount.fragments.moneyFragment.amount,
          let amountAsDouble = Double(amountAsString),
          let currency = paymentIncrementFragment.amount.fragments.moneyFragment.currency?.rawValue else {
      return nil
    }

    guard let intervalAsTime = TimeInterval
      .from(ISO8601DateTimeString: paymentIncrementFragment.scheduledCollection) else {
      return nil
    }

    self.amount = PledgePaymentIncrementAmount(amount: amountAsDouble, currency: currency)
    self.scheduledCollection = intervalAsTime
    self.state = paymentIncrementFragment.state
  }
}
