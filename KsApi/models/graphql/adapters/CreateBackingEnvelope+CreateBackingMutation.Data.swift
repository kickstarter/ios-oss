import Foundation
import ReactiveSwift

extension CreateBackingEnvelope {
  static func from(_ data: GraphAPI.CreateBackingMutation.Data) -> CreateBackingEnvelope? {
    guard let checkout = Checkout.from(data.createBacking?.checkout?.fragments.checkoutFragment) else {
      return nil
    }

    return CreateBackingEnvelope(createBacking: CreateBacking(checkout: checkout))
  }

  static func producer(from data: GraphAPI.CreateBackingMutation
    .Data) -> SignalProducer<CreateBackingEnvelope, ErrorEnvelope> {
    guard let envelope = CreateBackingEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
