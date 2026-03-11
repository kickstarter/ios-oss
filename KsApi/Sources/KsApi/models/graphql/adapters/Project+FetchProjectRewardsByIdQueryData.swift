import Apollo
import GraphAPI
import Prelude
import ReactiveSwift

extension Project {
  static func projectRewardsProducer(
    from data: GraphAPI.FetchProjectRewardsByIdQuery.Data
  ) -> SignalProducer<[Reward], ErrorEnvelope> {
    let projectRewards = Project.projectRewards(from: data)

    return SignalProducer(value: projectRewards)
  }

  static func projectRewards(from data: GraphAPI.FetchSortedProjectRewardsByIdQuery.Data) -> [Reward] {
    guard let project = data.project else {
      return []
    }

    let projectRewards = project.rewards?.nodes?
      .compactMap { node -> Reward? in
        guard let node else {
          return nil
        }

        let rewardFragment = node.fragments.rewardFragment
        let shippingRuleFragment = node.fragments.simpleShippingRulesExpandedFragment
        let expandedShippingRules = ShippingRule.simpleShippingRulesExpanded(from: shippingRuleFragment)

        return Reward.reward(from: rewardFragment, expandedShippingRules: expandedShippingRules)
      } ?? []

    let noReward = Reward.noRewardReward(from: project.fragments.noRewardRewardFragment)
    return [noReward] + projectRewards
  }

  static func projectRewards(from data: GraphAPI.FetchProjectRewardsByIdQuery.Data) -> [Reward] {
    let projectRewards = data.project?.rewards?.nodes?
      .compactMap { node -> Reward? in
        guard let node else {
          return nil
        }

        let rewardFragment = node.fragments.rewardFragment

        guard let shippingRuleFragment = node.fragments.simpleShippingRulesExpandedFragment else {
          return Reward.reward(from: rewardFragment, expandedShippingRules: nil)
        }

        let expandedShippingRules = ShippingRule.simpleShippingRulesExpanded(from: shippingRuleFragment)
        return Reward.reward(from: rewardFragment, expandedShippingRules: expandedShippingRules)
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
