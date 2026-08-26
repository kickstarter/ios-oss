import Apollo
import GraphAPI
import Prelude
import ReactiveSwift

/// A protocol that defines how we want to insert the `No Reward` into the overall rewards list.
///
/// The project rewards fetched by `FetchSortedProjectRewardsByIdQuery` are sorted on the backend -
/// but 'No Reward' is inserted by the frontend.
///
/// This is pulled out into its own protocol so that we can implement more complex sort behavior, including context that
/// KsApi doesn't necessarily have.
public protocol NoRewardInserter {
  func insert(noReward: Reward, intoRewards: [Reward]) -> [Reward]
}

extension Project {
  static func projectRewardsProducer(
    from data: GraphAPI.FetchProjectRewardsByIdQuery.Data
  ) -> SignalProducer<[Reward], ErrorEnvelope> {
    let projectRewards = Project.projectRewards(from: data)

    return SignalProducer(value: projectRewards)
  }

  static func projectRewards(
    from data: GraphAPI.FetchSortedProjectRewardsByIdQuery.Data,
    withNoReward inserter: NoRewardInserter
  ) -> [Reward] {
    guard let project = data.project else {
      return []
    }

    let projectRewards = project.rewards?.nodes?
      .compactMap { node -> Reward? in
        guard let node else {
          return nil
        }

        let rewardFragment = node.fragments.rewardFragment
        let shippingRuleFragment = node.fragments.rewardSimpleShippingRulesExpandedFragment
        let expandedShippingRules = ShippingRule.simpleShippingRulesExpanded(from: shippingRuleFragment)
        let imageFragment = node.fragments.rewardImageFragment
        let itemFragment = node.fragments.rewardItemsFragment

        return Reward.reward(
          from: rewardFragment,
          expandedShippingRules: expandedShippingRules,
          rewardItems: RewardsItem.rewardItemsData(from: itemFragment),
          rewardImage: Reward.Image.rewardPhoto(from: imageFragment)
        )
      } ?? []

    let noReward = Reward.noRewardReward(from: project.fragments.noRewardRewardFragment)
    return inserter.insert(noReward: noReward, intoRewards: projectRewards)
  }

  static func projectRewards(from data: GraphAPI.FetchProjectRewardsByIdQuery.Data) -> [Reward] {
    let projectRewards = data.project?.rewards?.nodes?
      .compactMap { node -> Reward? in
        guard let node else {
          return nil
        }

        let rewardFragment = node.fragments.rewardFragment
        let imageFragment = node.fragments.rewardImageFragment
        let itemFragment = node.fragments.rewardItemsFragment

        guard let shippingRuleFragment = node.fragments.rewardSimpleShippingRulesExpandedFragment else {
          return Reward.reward(
            from: rewardFragment,
            expandedShippingRules: nil,
            rewardItems: RewardsItem.rewardItemsData(from: itemFragment),
            rewardImage: Reward.Image.rewardPhoto(from: imageFragment)
          )
        }

        let expandedShippingRules = ShippingRule.simpleShippingRulesExpanded(from: shippingRuleFragment)
        return Reward.reward(
          from: rewardFragment,
          expandedShippingRules: expandedShippingRules,
          rewardItems: RewardsItem.rewardItemsData(from: itemFragment),
          rewardImage: Reward.Image.rewardPhoto(from: imageFragment)
        )
      }
    return projectRewards ?? []
  }

  static func projectRewardsAndPledgeOverTimeDataProducer(
    from data: GraphAPI.FetchProjectRewardsByIdQuery.Data
  ) -> SignalProducer<
    RewardsAndPledgeOverTimeEnvelope,
    ErrorEnvelope
  > {
    let projectRewards = Project.projectRewardsAndPledgeOverTimeData(from: data)

    return SignalProducer(value: projectRewards)
  }

  static func projectRewardsAndPledgeOverTimeData(
    from data: GraphAPI.FetchProjectRewardsByIdQuery
      .Data
  ) -> RewardsAndPledgeOverTimeEnvelope {
    let rewards = self.projectRewards(from: data)

    guard let pledgeOverTimeFragment = data.project?.fragments.pledgeOverTimeFragment else {
      return RewardsAndPledgeOverTimeEnvelope(
        rewards: rewards,
        isPledgeOverTimeAllowed: false,
        pledgeOverTimeCollectionPlanChargeExplanation: nil,
        pledgeOverTimeCollectionPlanChargedAsNPayments: nil,
        pledgeOverTimeCollectionPlanShortPitch: nil,
        pledgeOverTimeMinimumExplanation: nil
      )
    }

    return RewardsAndPledgeOverTimeEnvelope(
      rewards: rewards,
      isPledgeOverTimeAllowed: pledgeOverTimeFragment.isPledgeOverTimeAllowed,
      pledgeOverTimeCollectionPlanChargeExplanation: pledgeOverTimeFragment
        .pledgeOverTimeCollectionPlanChargeExplanation,
      pledgeOverTimeCollectionPlanChargedAsNPayments: pledgeOverTimeFragment
        .pledgeOverTimeCollectionPlanChargedAsNPayments,
      pledgeOverTimeCollectionPlanShortPitch: pledgeOverTimeFragment.pledgeOverTimeCollectionPlanShortPitch,
      pledgeOverTimeMinimumExplanation: pledgeOverTimeFragment.pledgeOverTimeMinimumExplanation
    )
  }
}
