import Foundation

public extension Reward {
  static func reward(
    from backingReward: ManagePledgeViewBackingEnvelope.Backing.Reward,
    project: Project,
    selectedAddOnQuantities: [String: Int],
    dateFormatter: ISO8601DateFormatter
  ) -> Reward {
    let estimatedDeliveryOn = backingReward.estimatedDeliveryOn
      .flatMap(dateFormatter.date(from:))?.timeIntervalSince1970

    let addOnData = selectedAddOnQuantities[backingReward.id]
      .flatMap(AddOnData.init(selectedQuantity:))

    return Reward(
      addOnData: addOnData,
      backersCount: backingReward.backersCount,
      convertedMinimum: calculateConvertedMinimum(from: backingReward, with: project),
      description: backingReward.description,
      endsAt: backingReward.endsAt,
      estimatedDeliveryOn: estimatedDeliveryOn,
      id: Int(backingReward.id) ?? -1,
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
    guard let id = Int(item.id) else { return nil }

    // FIXME:
    return RewardsItem(
      id: id,
      // doesn't exist
      item: Item(
        description: nil,
        id: 0,
        name: item.name,
        projectId: project.id
      ),
      quantity: 0,
      rewardId: Int(backingReward.id) ?? -1
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
