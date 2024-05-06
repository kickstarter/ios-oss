import Foundation
import ReactiveSwift

public struct ValidateCheckoutEnvelope: Decodable {}

// MARK: - GraphQL Adapters

extension ValidateCheckoutEnvelope {
  /**
   Returns a `ValidateCheckoutEnvelope` or `ErrorEnveloper` from a `GraphAPI.ValidateCheckoutQuery.Data`
   */
  static func envelopeProducer(from data: GraphAPI.ValidateCheckoutQuery.Data)
    -> SignalProducer<ValidateCheckoutEnvelope, ErrorEnvelope> {
    if data.checkout?.isValidForOnSessionCheckout.valid == true {
      return SignalProducer(value: ValidateCheckoutEnvelope())
    }

    let errorMessage = data.checkout?.isValidForOnSessionCheckout.messages.first ?? ""
    return SignalProducer(error: .validateCheckoutError(errorMessage))
  }
}
