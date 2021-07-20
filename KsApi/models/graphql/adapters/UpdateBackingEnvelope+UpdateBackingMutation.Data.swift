import Foundation
import ReactiveSwift

extension UpdateBackingEnvelope {
  /**
   Map `GraphAPI.UpdateBackingMutation.Data` to a `UpdateBackingEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.UpdateBackingMutation.Data) -> UpdateBackingEnvelope? {
    guard let checkout = Checkout.from(data.updateBacking?.checkout?.fragments.checkoutFragment) else {
      return nil
    }

    return UpdateBackingEnvelope(updateBacking: UpdateBacking(checkout: checkout))
  }

  /**
   Return a signal producer containing `UpdateBackingEnvelope` or `ErrorEnvelope`
   */
  static func producer(from data: GraphAPI.UpdateBackingMutation
    .Data) -> SignalProducer<UpdateBackingEnvelope, ErrorEnvelope> {
    guard let envelope = UpdateBackingEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
