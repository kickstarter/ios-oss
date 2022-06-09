import Foundation
import Prelude

extension Reward {
  internal static let template = Reward(
    backersCount: 50,
    convertedMinimum: 10.00,
    description: "A cool thing",
    endsAt: nil,
    estimatedDeliveryOn: Date(
      timeIntervalSince1970: 1_475_361_315
    ).timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 365.0,
    hasAddOns: false,
    id: 1,
    limit: 100,
    limitPerBacker: nil,
    minimum: 10.00,
    remaining: 50,
    rewardsItems: [RewardsItem.template],
    shipping: Reward.Shipping(
      enabled: false,
      location: nil,
      preference: Reward.Shipping.Preference.none,
      summary: nil,
      type: nil
    ),
    shippingRules: nil,
    shippingRulesExpanded: nil,
    startsAt: nil,
    title: "My Reward",
    localPickup: nil
  )

  public static let noReward = Reward(
    backersCount: nil,
    convertedMinimum: 0,
    description: "",
    endsAt: nil,
    estimatedDeliveryOn: nil,
    hasAddOns: false,
    id: 0,
    limit: nil,
    limitPerBacker: nil,
    minimum: 0,
    remaining: nil,
    rewardsItems: [],
    shipping: Reward.Shipping(
      enabled: false,
      location: nil,
      preference: Reward.Shipping.Preference.none,
      summary: nil,
      type: nil
    ),
    shippingRules: nil,
    shippingRulesExpanded: nil,
    startsAt: nil,
    title: nil,
    localPickup: nil
  )

  public static let otherReward = Reward(
    backersCount: nil,
    convertedMinimum: 0,
    description: "",
    endsAt: nil,
    estimatedDeliveryOn: nil,
    hasAddOns: false,
    id: 9_999,
    limit: nil,
    limitPerBacker: nil,
    minimum: 0,
    remaining: nil,
    rewardsItems: [],
    shipping: Reward.Shipping(
      enabled: false,
      location: nil,
      preference: Reward.Shipping.Preference.none,
      summary: nil,
      type: nil
    ),
    shippingRules: nil,
    shippingRulesExpanded: nil,
    startsAt: nil,
    title: nil,
    localPickup: nil
  )

  public static let postcards = Reward.template
    |> Reward.lens.id .~ 20
    |> Reward.lens.minimum .~ 6.0
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 50
    |> Reward.lens.backersCount .~ 23
    |> Reward.lens.title .~ "Postcards"
    |> Reward.lens.description .~ "Pack of 5 postcards - images from the Cosmic Surgery series."
    |> Reward.lens.localPickup .~ nil
    |> Reward.lens.rewardsItems .~ Array(1...5)
    .map { number in
      RewardsItem.template
        |> RewardsItem.lens.quantity .~ 1
        |> RewardsItem.lens.item .~ (
          .template
            |> Item.lens.name .~ "Post card \(number)"
        )
    }
}
