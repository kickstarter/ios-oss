import Foundation
import ReactiveSwift

public struct ValidateCheckoutEnvelope: Decodable {
  public let valid: Bool
  public let errorTypes: [String]
  public let messages: [String]
}

// MARK: - GraphQL Adapters

extension ValidateCheckoutEnvelope {
  static func envelopeProducer(from data: GraphAPI.ValidateCheckoutQuery.Data)
    -> SignalProducer<ValidateCheckoutEnvelope, ErrorEnvelope> {
    guard let envelope = ValidateCheckoutEnvelope.validateCheckoutEnvelope(from: data) else {
      return SignalProducer(error: .couldNotParseJSON)
    }
    return SignalProducer(value: envelope)
  }

  /**
   Returns a minimal `ValidateCheckoutEnvelope` from a `GraphAPI.ValidateCheckoutQuery.Data`
   */
  static func validateCheckoutEnvelope(
    from data: GraphAPI.ValidateCheckoutQuery
      .Data
  ) -> ValidateCheckoutEnvelope? {
    guard let valid = data.checkout?.isValidForOnSessionCheckout.valid,
          let errorTypes = data.checkout?.isValidForOnSessionCheckout.errorTypes,
          let messages = data.checkout?.isValidForOnSessionCheckout.messages
    else { return nil }

    return ValidateCheckoutEnvelope(valid: valid, errorTypes: errorTypes, messages: messages)
  }
}
