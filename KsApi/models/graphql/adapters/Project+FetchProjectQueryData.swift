import Apollo
import Foundation
import ReactiveSwift

extension Project {
  public typealias ProjectPamphletData = (project: Project, backingId: Int?)

  static func projectProducer(
    from data: GraphAPI.FetchProjectByIdQuery.Data
  ) -> SignalProducer<ProjectPamphletData, ErrorEnvelope> {
    let projectAndBackingId = Project.project(from: data)

    guard let project = projectAndBackingId.0 else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let data = ProjectPamphletData(project: project, backingId: projectAndBackingId.1)

    return SignalProducer(value: data)
  }

  static func projectProducer(
    from data: GraphAPI.FetchProjectBySlugQuery.Data
  ) -> SignalProducer<ProjectPamphletData, ErrorEnvelope> {
    let projectAndBackingId = Project.project(from: data)

    guard let project = projectAndBackingId.0 else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let data = ProjectPamphletData(project: project, backingId: projectAndBackingId.1)

    return SignalProducer(value: data)
  }

  static func project(from data: GraphAPI.FetchProjectByIdQuery.Data) -> (Project?, Int?) {
    let addOns = data.project?.addOns?.nodes?
      .compactMap { node -> GraphAPI.RewardFragment? in
        guard let rewardFragment = node?.fragments.rewardFragment else { return nil }

        return rewardFragment
      }
      .compactMap { fragment in
        Reward.reward(from: fragment)
      }

    let rewards = data.project?.rewards?.nodes?
      .compactMap { node -> GraphAPI.RewardFragment? in
        guard let rewardFragment = node?.fragments.rewardFragment else { return nil }

        return rewardFragment
      }
      .compactMap { fragment in
        Reward.reward(from: fragment)
      } ?? []

    /**
     TODO: Ideally attaching backing here from a project query would simplify the query. However its' too complex, so we need to revisit this as we re-create the existing v1 model to a new GQL project model.
     */
    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(
        from: fragment,
        rewards: rewards,
        addOns: addOns,
        backing: nil,
        currentUserChosenCurrency: data.me?.chosenCurrency
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }

  static func project(from data: GraphAPI.FetchProjectBySlugQuery.Data) -> (Project?, Int?) {
    let addOns = data.project?.addOns?.nodes?
      .compactMap { node -> GraphAPI.RewardFragment? in
        guard let rewardFragment = node?.fragments.rewardFragment else { return nil }

        return rewardFragment
      }
      .compactMap { fragment in
        Reward.reward(from: fragment)
      }

    let rewards = data.project?.rewards?.nodes?
      .compactMap { node -> GraphAPI.RewardFragment? in
        guard let rewardFragment = node?.fragments.rewardFragment else { return nil }

        return rewardFragment
      }
      .compactMap { fragment in
        Reward.reward(from: fragment)
      } ?? []

    /**
     TODO: Ideally attaching backing here from a project query would simplify the query. However its' too complex, so we need to revisit this as we re-create the existing v1 model to a new GQL project model.
     */
    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(
        from: fragment,
        rewards: rewards,
        addOns: addOns,
        backing: nil,
        currentUserChosenCurrency: data.me?.chosenCurrency
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }
}
