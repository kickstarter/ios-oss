import Foundation
import ReactiveSwift
import Apollo

extension Project {
  static func projectProducer(
    from data: GraphAPI.FetchProjectByIdQuery.Data
  ) -> SignalProducer<Project, ErrorEnvelope> {
    guard let project = Project.project(from: data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: project)
  }

  static func projectProducer(
    from data: GraphAPI.FetchProjectBySlugQuery.Data
  ) -> SignalProducer<Project, ErrorEnvelope> {
    guard let project = Project.project(from: data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: project)
  }

  static func project(from data: GraphAPI.FetchProjectByIdQuery.Data) -> Project? {
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

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(from: fragment, rewards: rewards, addOns: addOns)
    else { return nil }

    return project
  }

  static func project(from data: GraphAPI.FetchProjectBySlugQuery.Data) -> Project? {
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

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(from: fragment, rewards: rewards, addOns: addOns)
    else { return nil }

    return project
  }
}
