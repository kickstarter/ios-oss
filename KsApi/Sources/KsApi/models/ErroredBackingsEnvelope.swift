import Foundation
import GraphAPI
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
  static func producer(
    from data: GraphAPI.FetchUserBackingsQuery
      .Data
  ) -> SignalProducer<ErroredBackingsEnvelope, ErrorEnvelope> {
    guard let envelopes = data.me?.backings?.nodes?.compactMap({ node -> ProjectAndBackingEnvelope? in

      var paymentIncrements: [PledgePaymentIncrement] = []

      if let backingIncrements = node?.paymentIncrements {
        paymentIncrements = backingIncrements
          .compactMap {
            PledgePaymentIncrement(
              withGraphQLFragment: $0.fragments
                .paymentIncrementFragment
            )
          }
      }

      guard let backingFragment = node?.fragments.backingFragment,
            let projectFragment = node?.project?.fragments.projectFragment,
            let backing = Backing.backing(from: backingFragment, paymentIncrements: paymentIncrements),
            let project = Project.project(from: projectFragment, currentUserChosenCurrency: nil)
      else { return nil }

      return ProjectAndBackingEnvelope(project: project, backing: backing)
    }) else { return SignalProducer(error: .couldNotParseJSON) }

    return SignalProducer(value: ErroredBackingsEnvelope(projectsAndBackings: envelopes))
  }
}
