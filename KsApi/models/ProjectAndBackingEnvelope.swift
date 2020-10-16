import Foundation
import ReactiveSwift

public struct ProjectAndBackingEnvelope: Equatable {
  public var project: Project
  public var backing: Backing
}

extension ProjectAndBackingEnvelope: Decodable {
  public static func decode(_: JSON) -> Decoded<ProjectAndBackingEnvelope> {
    fatalError("Conformance is to satisfy the compiler, do not create this model using Argo")
  }
}

// MARK: - GraphQL Adapters

extension ProjectAndBackingEnvelope {
  internal static func envelopeProducer(
    from envelope: ManagePledgeViewBackingEnvelope
  ) -> SignalProducer<ProjectAndBackingEnvelope, ErrorEnvelope> {
    guard
      let project = Project.project(from: envelope.project),
      let backing = Backing.backing(from: envelope.backing)
    else { return SignalProducer(error: .couldNotParseJSON) }

    return SignalProducer(value: ProjectAndBackingEnvelope(project: project, backing: backing))
  }
}
