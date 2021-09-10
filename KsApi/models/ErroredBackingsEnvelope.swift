import Foundation
import ReactiveSwift

public struct ErroredBackingsEnvelope {
  public let projectsAndBackings: [ProjectAndBackingEnvelope]
}

// MARK: - GraphQL Adapters

extension ErroredBackingsEnvelope {
  /**
   Returns a `SignalProducer` containing either a `ErroredBackingsEnvelope` on success  or an `ErrorEnvelope`.

   - parameter from: The `GraphAPI.FetchUserBackingsQuery.Data` object that contains the backings and fragment details.
   */
  static func producer(from data: GraphAPI.FetchUserBackingsQuery
    .Data) -> SignalProducer<ErroredBackingsEnvelope, ErrorEnvelope> {
    guard let envelopes = data.me?.backings?.nodes?.compactMap({ backing -> ProjectAndBackingEnvelope? in
      guard let backingFragment = backing?.fragments.backingFragment,
        let backing = Backing.backing(from: backingFragment),
        let projectFragment = backingFragment.project?.fragments.projectFragment,
        let project = Project.project(from: projectFragment, currentUserChosenCurrency: nil)
      else { return nil }

      return ProjectAndBackingEnvelope(project: project, backing: backing)
    }) else { return SignalProducer(error: .couldNotParseJSON) }

    return SignalProducer(value: ErroredBackingsEnvelope(projectsAndBackings: envelopes))
  }
}
