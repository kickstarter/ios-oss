import Foundation

public extension Reward {
  /**
   Create an add-on reward from a ManagePledgeViewBackingEnvelope.Backing.Reward

    - parameter backingReward: The ManagePledgeViewBackingEnvelope.Backing.Reward data structure.
    - parameter project: The associated Project model.
    - parameter selectedAddOnQuantities: The selected quantity for this add-on.
    - parameter dateFormatter: A DateFormatter configured with the format "yyyy-MM-DD".

    - returns: A Reward.
   */

  static func addOnReward(
    from backingReward: ManagePledgeViewBackingEnvelope.Backing.Reward,
    project: Project,
    selectedAddOnQuantities: [String: Int],
    dateFormatter: DateFormatter
  ) -> Reward? {
    guard let rewardId = decompose(id: backingReward.id) else { return nil }

    let estimatedDeliveryOn = backingReward.estimatedDeliveryOn
      .flatMap(dateFormatter.date(from:))?.timeIntervalSince1970

    let addOnData = AddOnData(
      isAddOn: true,
      selectedQuantity: selectedAddOnQuantities[backingReward.id] ?? 0
    )

    return Reward(
      addOnData: addOnData,
      backersCount: backingReward.backersCount,
      convertedMinimum: calculateConvertedMinimum(from: backingReward, with: project),
      description: backingReward.description,
      endsAt: backingReward.endsAt,
      estimatedDeliveryOn: estimatedDeliveryOn,
      id: rewardId,
      limit: backingReward.limit,
      minimum: backingReward.amount.amount,
      remaining: backingReward.remainingQuantity,
      rewardsItems: rewardItemsData(from: backingReward, with: project),
      shipping: shippingData(from: backingReward),
      startsAt: backingReward.startsAt,
      title: backingReward.name
    )
  }
}

private func calculateConvertedMinimum(
  from backingReward: ManagePledgeViewBackingEnvelope.Backing.Reward,
  with project: Project
) -> Double {
  let rate = project.stats.currentCurrencyRate ?? project.stats.staticUsdRate

  return Double(Int(ceil(Float(backingReward.amount.amount) * rate)))
}

private func rewardItemsData(
  from backingReward: ManagePledgeViewBackingEnvelope.Backing.Reward,
  with project: Project
) -> [RewardsItem] {
  return backingReward.items?.compactMap { item -> RewardsItem? in
    guard
      let id = Int(item.id),
      let rewardId = decompose(id: backingReward.id)
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
  from backingReward: ManagePledgeViewBackingEnvelope.Backing.Reward
) -> Reward.Shipping {
  // For AddOns we are only concerned with whether or not shipping is enabled and the delivery date
  return Reward.Shipping(
    enabled: backingReward.estimatedDeliveryOn != nil,
    location: nil,
    preference: nil,
    summary: nil,
    type: nil
  )
}
