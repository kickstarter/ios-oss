import Foundation

public extension Reward {
  static func reward(
    from backingReward: ManagePledgeViewBackingEnvelope.Backing.Reward,
    dateFormatter: ISO8601DateFormatter
  ) -> Reward {
    let estimatedDeliveryOn = backingReward.estimatedDeliveryOn
      .flatMap(dateFormatter.date(from:))?.timeIntervalSince1970

    return Reward(
      backersCount: backingReward.backersCount,
      convertedMinimum: 0, // FIXME: can be inferred from project (see below)
      description: backingReward.description,
      endsAt: backingReward.endsAt,
      estimatedDeliveryOn: estimatedDeliveryOn,
      id: Int(backingReward.id) ?? -1,
      limit: backingReward.limit,
      minimum: backingReward.amount.amount,
      remaining: backingReward.remainingQuantity,
      rewardsItems: rewardItemsData(from: backingReward),
      shipping: shippingData(from: backingReward),
      startsAt: backingReward.startsAt,
      title: backingReward.name
    )
  }
}

/*
 let (country, rate) = zip(
   project.stats.currentCountry,
   project.stats.currentCurrencyRate
 ) ?? (.us, project.stats.staticUsdRate)

 Int(ceil(Float(reward.amount) * rate))
 */

private func rewardItemsData(
  from _: ManagePledgeViewBackingEnvelope.Backing.Reward
) -> [RewardsItem] {
  return []
  /*
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
         projectId: 0
       ),
       quantity: 0,
       rewardId: 0
     )
   } ?? []
   */
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
