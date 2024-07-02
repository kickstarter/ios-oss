import Foundation
import ReactiveSwift

public struct CompleteOrderEnvelope: Decodable {
  public var clientSecret: String
  public var status: String
  
  static func from(_ data: GraphAPI.CompleteOrderMutation.Data) -> CompleteOrderEnvelope? {
    guard let clientSecret = data.completeOrder?.clientSecret, let status = data.completeOrder?.status else {
      return nil
    }

    return CompleteOrderEnvelope(clientSecret: clientSecret, status: status)
  }
  
  static func producer(
    from data: GraphAPI.CompleteOrderMutation.Data
  ) -> SignalProducer<CompleteOrderEnvelope, ErrorEnvelope> {
    guard let envelope = CompleteOrderEnvelope.from(data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: envelope)
  }
}
