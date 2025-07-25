import Foundation
import GraphAPI
import ReactiveSwift

public struct CreateCheckoutEnvelope: Decodable {
  public var checkout: Checkout

  public struct Checkout: Decodable {
    public var id: String
    public var paymentUrl: String
    public var backingId: String
  }
}

// MARK: - GraphQL Adapters

extension CreateCheckoutEnvelope {
  static func from(_ data: GraphAPI.CreateCheckoutMutation.Data) -> CreateCheckoutEnvelope? {
    guard let id = data.createCheckout?.checkout?.id,
          let paymentUrl = data.createCheckout?.checkout?.paymentUrl,
          let backingId = data.createCheckout?.checkout?.backing.id else {
      return nil
    }

    return CreateCheckoutEnvelope(checkout: Checkout(id: id, paymentUrl: paymentUrl, backingId: backingId))
  }

  static func producer(from data: GraphAPI.CreateCheckoutMutation.Data)
    -> SignalProducer<CreateCheckoutEnvelope, ErrorEnvelope> {
    guard let envelope = CreateCheckoutEnvelope.from(data) else {
      return SignalProducer(error: .couldNotParseJSON)
    }
    return SignalProducer(value: envelope)
  }
}
