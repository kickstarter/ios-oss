import Apollo
import Foundation
import Prelude
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

    let emptyRewards = [noRewardReward(from: data.project?.fragments.projectFragment)]
    let updatedRewardsWithNoReward = emptyRewards + rewards

    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(
        from: fragment,
        rewards: updatedRewardsWithNoReward,
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

    let emptyRewards = [noRewardReward(from: data.project?.fragments.projectFragment)]
    let updatedRewardsWithNoReward = emptyRewards + rewards

    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let project = Project.project(
        from: fragment,
        rewards: updatedRewardsWithNoReward,
        addOns: addOns,
        backing: nil,
        currentUserChosenCurrency: data.me?.chosenCurrency
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }

  /** FIXME: This is unfortunately a consequence of the no-reward reward being returned on v1 but not in GQL. Eventually we'll want to talk with backend about the possibility of returning a no-reward reward as part of the project query, just as they did with v1. The benefit of that is no reward reward doesn't have to be maintained locally. We want to show the rewards that the backend returns without modification to the raw data.
   */

  private static func noRewardReward(from fragment: GraphAPI.ProjectFragment?) -> Reward {
    var projectMinimumPledgeAmount = 1.0
    var currentUsersCurrencyFXRate = 1.0

    if let fxRateValue = fragment?.fxRate {
      currentUsersCurrencyFXRate = Double(fxRateValue)
    }

    if let projectMinPledgeSingleTierRawValue = fragment?.minPledge {
      projectMinimumPledgeAmount = Double(projectMinPledgeSingleTierRawValue)
    }

    let convertedMinimumAmount = currentUsersCurrencyFXRate * projectMinimumPledgeAmount

    let emptyReward = Reward.noReward
      |> Reward.lens.minimum .~ projectMinimumPledgeAmount
      |> Reward.lens.convertedMinimum .~ convertedMinimumAmount

    return emptyReward
  }
}
