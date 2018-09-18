import Prelude

extension Reward {
  internal static let template = Reward(
    backersCount: 50,
    description: "A cool thing",
    endsAt: nil,
    estimatedDeliveryOn: Date(
      timeIntervalSince1970: 1475361315).timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 365.0,
    id: 1,
    limit: 100,
    minimum: 10.00,
    remaining: 50,
    rewardsItems: [],
    shipping: Reward.Shipping(
      enabled: false,
      preference: nil,
      summary: nil
    ),
    startsAt: nil,
    title: nil
  )

  public static let noReward = Reward(
    backersCount: nil,
    description: "",
    endsAt: nil,
    estimatedDeliveryOn: nil,
    id: 0,
    limit: nil,
    minimum: 0,
    remaining: nil,
    rewardsItems: [],
    shipping: Reward.Shipping(enabled: false, preference: nil, summary: nil
    ),
    startsAt: nil,
    title: nil
  )
}
