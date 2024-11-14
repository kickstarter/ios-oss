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
        // Names are not localized and should not be shown to users, but they contain the data we
        // need to calculate shipping, just in a different initial format.
        let expandedShippingRules = node?.simpleShippingRulesExpanded?
          .compactMap { node -> ShippingRule? in
            guard let node,
                  let idString = node.locationId, let locationId = decompose(id: idString),
                  let name = node.locationName,
                  let cost = node.cost.flatMap(Double.init)
            else {
              return nil
            }

            let location = Location(
              country: node.country,
              displayableName: name,
              id: locationId,
              localizedName: name,
              name: name
            )

            let currency = node.currency.flatMap { Money.CurrencyCode(rawValue: $0) }
            let estimatedMin = node.estimatedMin.flatMap(Double.init)
              .flatMap { Money(amount: $0, currency: currency) }
            let estimatedMax = node.estimatedMax.flatMap(Double.init)
              .flatMap { Money(amount: $0, currency: currency) }

            return ShippingRule(
              cost: cost,
              id: nil,
              location: location,
              estimatedMin: estimatedMin,
              estimatedMax: estimatedMax
            )
          }

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
