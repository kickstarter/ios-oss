import Foundation
import ReactiveSwift

public struct ProjectAndBackingEnvelope: Equatable {
  public var project: Project
  public var backing: Backing
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
