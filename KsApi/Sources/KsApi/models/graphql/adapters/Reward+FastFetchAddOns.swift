import GraphAPI
import ReactiveSwift

extension Reward {
  static func addOnsProducer(
    from data: GraphAPI.FastFetchAddOnsQuery.Data
  ) -> SignalProducer<[Reward], ErrorEnvelope> {
    guard let addOns = Reward.addOns(from: data) else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: addOns)
  }

  static func addOns(from data: GraphAPI.FastFetchAddOnsQuery.Data) -> [Reward]? {
    guard let baseReward = data.reward else { return nil }
    let addOns = baseReward.displayableAddons.nodes?
      .compactMap { node -> Reward? in
        guard let node else { return nil }

        let rewardFragment = node.fragments.rewardFragment
        let imageFragment = node.fragments.rewardImageFragment
        let itemFragment = node.fragments.rewardItemsFragment

        var shippingRules: [ShippingRule] = []
        if let shippingRuleData = node.shippingForLocation.shippingRule {
          let fragment = shippingRuleData.fragments.simpleShippingRuleFragment
          if let shippingRule = ShippingRule.shippingRule(from: fragment) {
            shippingRules.append(shippingRule)
          }
        }

        return Reward.reward(
          from: rewardFragment,
          expandedShippingRules: shippingRules,
          rewardItems: RewardsItem.rewardItemsData(from: itemFragment),
          rewardImage: Reward.Image.rewardPhoto(from: imageFragment)
        )
      }

    return addOns
  }
}
