import Foundation
import KsApi

extension PledgePaymentIncrement {
  init?(
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
  }
}
