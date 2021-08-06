import Foundation
import ReactiveSwift

extension ClearUserUnseenActivityEnvelope {
  /**
   Map `GraphAPI.ClearUserUnseenActivityMutation.Data` to a `ClearUserUnseenActivityEnvelope`, otherwise return `nil`
   */
  static func from(_ data: GraphAPI.ClearUserUnseenActivityMutation
    .Data) -> ClearUserUnseenActivityEnvelope? {
    guard let count = data.clearUserUnseenActivity?.activityIndicatorCount else { return nil }
    return ClearUserUnseenActivityEnvelope(activityIndicatorCount: count)
  }

  /**
   Return a signal producer containing `ClearUserUnseenActivityEnvelope` or `ErrorEnvelope`
   */
  static func producer(from data: GraphAPI.ClearUserUnseenActivityMutation
    .Data) -> SignalProducer<ClearUserUnseenActivityEnvelope, ErrorEnvelope> {
    guard let envelope = ClearUserUnseenActivityEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
