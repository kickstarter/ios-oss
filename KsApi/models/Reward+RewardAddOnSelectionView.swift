import Foundation

public extension Reward {
  /**
   Create an add-on reward from a RewardAddOnSelectionViewEnvelope.Project.Reward

    - parameter reward: The RewardAddOnSelectionViewEnvelope.Project.Reward data structure.
    - parameter project: The associated Project model.
    - parameter selectedAddOnQuantities: The selected quantity for this add-on.
    - parameter dateFormatter: A DateFormatter configured with the format "yyyy-MM-DD".

    - returns: A Reward.
   */

  static func addOnReward(
    from reward: RewardAddOnSelectionViewEnvelope.Project.Reward,
    project: Project,
    selectedAddOnQuantities: [String: Int],
    dateFormatter: DateFormatter
  ) -> Reward? {
    guard let rewardId = decompose(id: reward.id) else { return nil }

    let estimatedDeliveryOn = reward.estimatedDeliveryOn
      .flatMap(dateFormatter.date(from:))?.timeIntervalSince1970

    let addOnData = AddOnData(
      isAddOn: true,
      selectedQuantity: selectedAddOnQuantities[reward.id] ?? 0,
      limitPerBacker: reward.limitPerBacker
    )

    return Reward(
      addOnData: addOnData,
      backersCount: reward.backersCount,
      convertedMinimum: reward.convertedAmount.amount,
      description: reward.description,
      endsAt: reward.endsAt,
      estimatedDeliveryOn: estimatedDeliveryOn,
      hasAddOns: false, // This value is only sent via the v1 API to indicate that a base reward has add-ons
      id: rewardId,
      limit: reward.limit,
      minimum: reward.amount.amount,
      remaining: reward.remainingQuantity,
      rewardsItems: rewardItemsData(from: reward, with: project),
      shipping: shippingData(from: reward),
      shippingRules: shippingRulesData(from: reward),
      startsAt: reward.startsAt,
      title: reward.name
    )
  }
}

private func rewardItemsData(
  from reward: RewardAddOnSelectionViewEnvelope.Project.Reward,
  with project: Project
) -> [RewardsItem] {
  return reward.items?.nodes.compactMap { item -> RewardsItem? in
    guard
      let id = Int(item.id),
      let rewardId = decompose(id: reward.id)
    else { return nil }

    return RewardsItem(
      id: 0, // not returned
      item: Item(
        description: nil, // not returned
        id: id,
        name: item.name,
        projectId: project.id
      ),
      quantity: 0, // not needed
      rewardId: rewardId
    )
  } ?? []
}

private func shippingData(
  from reward: RewardAddOnSelectionViewEnvelope.Project.Reward
) -> Reward.Shipping {
  // For AddOns we are only concerned with whether or not shipping is enabled
  return Reward.Shipping(
    enabled: [.restricted, .unrestricted].contains(reward.shippingPreference),
    location: nil,
    preference: nil,
    summary: nil,
    type: nil
  )
}

private func shippingRulesData(
  from reward: RewardAddOnSelectionViewEnvelope.Project.Reward
) -> [ShippingRule]? {
  guard let shippingRules = reward.shippingRules else { return nil }

  return shippingRules.map { shippingRule in
    ShippingRule(
      cost: shippingRule.cost.amount,
      id: decompose(id: shippingRule.id),
      location: Location(
        country: shippingRule.location.country,
        displayableName: shippingRule.location.displayableName,
        id: decompose(id: shippingRule.location.id) ?? 0,
        localizedName: shippingRule.location.countryName,
        name: shippingRule.location.name
      )
    )
  }
}
