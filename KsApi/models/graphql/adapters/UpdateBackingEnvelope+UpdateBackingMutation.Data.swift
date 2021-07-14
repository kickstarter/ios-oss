import Foundation
import ReactiveSwift

extension UpdateBackingEnvelope {
  static func from(_ data: GraphAPI.UpdateBackingMutation.Data) -> UpdateBackingEnvelope? {
    guard let checkout = Checkout.from(data.updateBacking?.checkout?.fragments.checkoutFragment) else {
      return nil
    }

    return UpdateBackingEnvelope(updateBacking: UpdateBacking(checkout: checkout))
  }

  static func producer(from data: GraphAPI.UpdateBackingMutation
    .Data) -> SignalProducer<UpdateBackingEnvelope, ErrorEnvelope> {
    guard let envelope = UpdateBackingEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
