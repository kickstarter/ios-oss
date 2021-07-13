import Foundation
import ReactiveSwift

extension CreateBackingEnvelope {
  static func from(_ data: GraphAPI.CreateBackingMutation.Data) -> CreateBackingEnvelope? {
    guard let checkout = Checkout.from(data.createBacking?.checkout) else {
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

extension Checkout {
  static func from(_ data: GraphAPI.CreateBackingMutation.Data.CreateBacking.Checkout?) -> Checkout? {
    guard
      let data = data,
      let state = Checkout.State(rawValue: data.state.rawValue),
      let requiresAction = data.backing.requiresAction
    else { return nil }
    return Checkout(
      id: data.id,
      state: state,
      backing: Checkout.Backing(clientSecret: data.backing.clientSecret, requiresAction: requiresAction)
    )
  }
}
