import Argo
import Foundation
import ReactiveSwift

public struct BackingsEnvelope {
  public let backings: [Backing]
}

extension BackingsEnvelope: Argo.Decodable {
  public static func decode(_: JSON) -> Decoded<BackingsEnvelope> {
    fatalError("Conformance is to satisfy the compiler, do not create this model using Argo.")
  }
}

// MARK: - GraphQL Adapters

extension BackingsEnvelope {
  internal static func envelopeProducer(
    from envelope: GraphBackingEnvelope
  ) -> SignalProducer<BackingsEnvelope, ErrorEnvelope> {
    let backings = envelope.backings.nodes.compactMap(Backing.backing(from:))

    return SignalProducer(value: BackingsEnvelope(backings: backings))
  }
}
