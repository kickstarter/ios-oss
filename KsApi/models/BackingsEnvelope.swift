import Argo
import Foundation
import ReactiveSwift

/**
 FIXME: Can likely improve naming here, this was historically `BackingsEnvelope` because it was used to
 display errored backings in the app. We might want to be more specific with something like
 `ErroredBackingsEnvelope`.
 */

public struct BackingsEnvelope {
  public let projectsAndBackings: [ProjectAndBackingEnvelope]
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
    let envelopes = envelope.backings.nodes.compactMap { graphBacking -> ProjectAndBackingEnvelope? in
      guard
        let backing = Backing.backing(from: graphBacking),
        let graphProject = graphBacking.project,
        let project = Project.project(from: graphProject)
      else { return nil }

      return ProjectAndBackingEnvelope(project: project, backing: backing)
    }

    return SignalProducer(value: BackingsEnvelope(projectsAndBackings: envelopes))
  }
}
