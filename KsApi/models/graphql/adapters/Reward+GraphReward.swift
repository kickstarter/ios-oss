import Foundation

extension Reward {
  /**
   Creates a `Reward` from a `GraphReward`.

    - parameter reward: The `GraphReward` data structure.
    - parameter projectId: The associated Project's ID'.
    - parameter dateFormatter: A DateFormatter configured with the format "yyyy-MM-DD".

    - returns: A Reward.
   */

  static func reward(
    from graphReward: GraphReward,
    projectId: Int,
    dateFormatter: DateFormatter = DateFormatter.isoDateFormatter
  ) -> Reward? {
    guard let rewardId = decompose(id: graphReward.id) else { return nil }

    let estimatedDeliveryOn = graphReward.estimatedDeliveryOn
      .flatMap(dateFormatter.date(from:))?.timeIntervalSince1970

    return Reward(
      backersCount: graphReward.backersCount,
      convertedMinimum: graphReward.convertedAmount.amount,
      description: graphReward.description,
      endsAt: graphReward.endsAt,
      estimatedDeliveryOn: estimatedDeliveryOn,
      hasAddOns: false, // This value is only sent via the v1 API to indicate that a base reward has add-ons
      id: rewardId,
      limit: graphReward.limit,
      minimum: graphReward.amount.amount,
      remaining: graphReward.remainingQuantity,
      rewardsItems: rewardItemsData(from: graphReward, with: projectId),
      shipping: shippingData(from: graphReward),
      shippingRules: shippingRulesData(from: graphReward),
      startsAt: graphReward.startsAt,
      title: graphReward.name
    )
  }
}

private func rewardItemsData(
  from graphReward: GraphReward,
  with projectId: Int
) -> [RewardsItem] {
  return graphReward.items?.nodes.compactMap { item -> RewardsItem? in
    guard
      let id = decompose(id: item.id),
      let rewardId = decompose(id: graphReward.id)
    else { return nil }

    return RewardsItem(
      id: 0, // not returned
      item: Item(
        description: nil, // not returned
        id: id,
        name: item.name,
        projectId: projectId
      ),
      quantity: 0, // not needed
      rewardId: rewardId
    )
  } ?? []
}

// FIXME: currently we don't get all of this information via GraphQL
private func shippingData(
  from graphReward: GraphReward
) -> Reward.Shipping {
  return Reward.Shipping(
    enabled: [.restricted, .unrestricted].contains(graphReward.shippingPreference),
    location: nil,
    preference: nil,
    summary: nil,
    type: nil
  )
}

private func shippingRulesData(
  from graphReward: GraphReward
) -> [ShippingRule]? {
  guard let shippingRules = graphReward.shippingRules else { return nil }

  return shippingRules.compactMap { shippingRule -> ShippingRule? in
    guard let locationId = decompose(id: shippingRule.location.id) else { return nil }
    return ShippingRule(
      cost: shippingRule.cost.amount,
      id: decompose(id: shippingRule.id),
      location: Location(
        country: shippingRule.location.country,
        displayableName: shippingRule.location.displayableName,
        id: locationId,
        localizedName: shippingRule.location.name,
        name: shippingRule.location.name
      )
    )
  }
}
