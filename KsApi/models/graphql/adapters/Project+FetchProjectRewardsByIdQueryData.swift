import Apollo
import Prelude
import ReactiveSwift

extension Project {
  static func projectRewardsProducer(
    from data: GraphAPI.FetchProjectRewardsByIdQuery.Data
  ) -> SignalProducer<[Reward], ErrorEnvelope> {
    let projectRewards = Project.projectRewards(from: data)

    return SignalProducer(value: projectRewards)
  }

  static func projectRewards(from data: GraphAPI.FetchProjectRewardsByIdQuery.Data) -> [Reward] {
    let projectRewards = data.project?.rewards?.nodes?
      .compactMap { node -> (GraphAPI.RewardFragment, [ShippingRule]?)? in
        guard let rewardFragment = node?.fragments.rewardFragment else { return nil }

        // These shipping rules are constructed from simplified versions of the shipping rules.
        // They should NOT be used for final pledge calculations.
        let expandedShippingRules = node?.simpleShippingRulesExpanded?
          .compactMap { node -> ShippingRule? in
            guard let node,
                  let idString = node.locationId, let locationId = decompose(id: idString)
            else {
              return nil
            }
            let cost = Double(node.cost ?? "") ?? 0.0
            let name = node.locationName ?? ""
            let location = Location.init(
              country: node.country,
              displayableName: name,
              id: locationId,
              localizedName: name,
              name: name
            )
            return ShippingRule(
              cost: cost,
              id: nil,
              location: location,
              estimatedMin: nil,
              estimatedMax: nil
            )
          }
          .compactMap { $0 }

        return (rewardFragment, expandedShippingRules)
      }
      .compactMap { (
        rewardFragment: GraphAPI.RewardFragment,
        expandedShippingRules: [ShippingRule]?
      ) -> Reward? in
        Reward.reward(from: rewardFragment, expandedShippingRules: expandedShippingRules)
      }
    return projectRewards ?? []
  }
}
