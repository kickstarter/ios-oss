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
    if let stateValue = fragment.state.value {
      self.state = PledgePaymentIncrementState(stateValue: stateValue)
    }

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
