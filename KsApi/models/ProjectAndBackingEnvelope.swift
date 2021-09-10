import Foundation
import ReactiveSwift

public struct ProjectAndBackingEnvelope: Equatable {
  public var project: Project
  public var backing: Backing
}

// MARK: - GraphQL Adapters

extension ProjectAndBackingEnvelope {
  static func envelopeProducer(
    from data: GraphAPI.FetchBackingQuery.Data
  ) -> SignalProducer<ProjectAndBackingEnvelope, ErrorEnvelope> {
    let addOns = data.backing?.addOns?.nodes?
      .compactMap { $0 }
      .compactMap { $0.fragments.rewardFragment }
      .compactMap { Reward.reward(from: $0) }

    guard
      let backingFragment = data.backing?.fragments.backingFragment,
      let projectFragment = data.backing?.fragments.backingFragment.project?.fragments.projectFragment,
      let backing = Backing.backing(from: backingFragment, addOns: addOns),
      let project = Project.project(from: projectFragment, backing: backing, currentUserChosenCurrency: nil)
    else {
      return SignalProducer(error: .couldNotParseJSON)
    }

    return SignalProducer(value: ProjectAndBackingEnvelope(project: project, backing: backing))
  }
}
