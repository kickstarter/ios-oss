import Foundation
import ReactiveSwift

public struct ValidateCheckoutEnvelope: Decodable {
  public let messages: [String]
}

// MARK: - GraphQL Adapters

extension ValidateCheckoutEnvelope {
  static func envelopeProducer(from data: GraphAPI.ValidateCheckoutQuery.Data)
    -> SignalProducer<ValidateCheckoutEnvelope, ErrorEnvelope> {
    guard let envelope = ValidateCheckoutEnvelope.validateCheckoutEnvelope(from: data) else {
      return SignalProducer(error: .couldNotParseJSON)
    }

    guard data.checkout?.isValidForOnSessionCheckout.valid == true else {
      return SignalProducer(error: .validateCheckoutError(envelope.messages.first ?? ""))
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
    guard let messages = data.checkout?.isValidForOnSessionCheckout.messages
    else { return nil }

    return ValidateCheckoutEnvelope(messages: messages)
  }
}
