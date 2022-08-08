import Foundation
import ReactiveSwift

public struct ClientSecretEnvelope: Decodable {
  public let clientSecret: String
}

// MARK: - GraphQL Adapters

extension ClientSecretEnvelope {
  static func envelopeProducer(from data: GraphAPI.CreateSetupIntentMutation.Data)
    -> SignalProducer<ClientSecretEnvelope, ErrorEnvelope> {
    guard let envelope = ClientSecretEnvelope.clientSecretEnvelope(from: data) else {
      return SignalProducer(error: .couldNotParseJSON)
    }
    return SignalProducer(value: envelope)
  }
}
