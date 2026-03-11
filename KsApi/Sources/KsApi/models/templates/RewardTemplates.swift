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
    featured: false,
    hasAddOns: false,
    id: 1,
    latePledgeAmount: 10.00,
    limit: 100,
    limitPerBacker: nil,
    minimum: 10.00,
    pledgeAmount: 10.00,
    postCampaignPledgingEnabled: false,
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
    localPickup: nil,
    isAvailable: nil,
    image: nil,
    audienceData: AudienceData(isSecretReward: false)
  )

  public static let noReward = Reward(
    backersCount: nil,
    convertedMinimum: 0,
    description: "",
    endsAt: nil,
    estimatedDeliveryOn: nil,
    featured: false,
    hasAddOns: false,
    id: 0,
    latePledgeAmount: 0,
    limit: nil,
    limitPerBacker: nil,
    minimum: 0,
    pledgeAmount: 0,
    postCampaignPledgingEnabled: false,
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
    localPickup: nil,
    isAvailable: nil,
    image: nil,
    audienceData: AudienceData(isSecretReward: false)
  )

  public static let otherReward = Reward(
    backersCount: nil,
    convertedMinimum: 0,
    description: "",
    endsAt: nil,
    estimatedDeliveryOn: nil,
    featured: false,
    hasAddOns: false,
    id: 9_999,
    latePledgeAmount: 0,
    limit: nil,
    limitPerBacker: nil,
    minimum: 0,
    pledgeAmount: 0,
    postCampaignPledgingEnabled: false,
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
    localPickup: nil,
    isAvailable: nil,
    image: nil,
    audienceData: AudienceData(isSecretReward: false)
  )

  public static let postcards = Reward.template
    |> Reward.lens.id .~ 20
    |> Reward.lens.minimum .~ 6.0
    |> Reward.lens.pledgeAmount .~ 0.0 // Default value if missing from server.
    |> Reward.lens.latePledgeAmount .~ 0.0 // Default value if missing from server.
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

  public static let secretRewardTemplate = Reward.template
    |> Reward.lens.title .~ "Super secret reward"
    |> Reward.lens.id .~ 9_876
    |> Reward.lens.isAvailable .~ true
    |> Reward.lens.audienceData .~ Reward.AudienceData(isSecretReward: true)

  internal static let shipsToUSAReward: Reward = Reward.template
    |> Reward.lens.title .~ "Ships only to the USA"
    |> Reward.lens.shipping .~ Reward.Shipping(
      enabled: true,
      location: nil,
      preference: .restricted,
      summary: "Ships to USA",
      type: nil
    )
    |> Reward.lens.shippingRulesExpanded .~ [
      ShippingRule(
        cost: 10,
        id: 0,
        location: Location.usa,
        estimatedMin: nil,
        estimatedMax: nil
      )
    ]
    |> Reward.lens.limit .~ 5
    |> Reward.lens.remaining .~ 5
    |> Reward.lens.isAvailable .~ true

  internal static let shipsToAustraliaReward = Reward.template
    |> Reward.lens.title .~ "Ships only to Australia"
    |> Reward.lens.shipping .~ Reward.Shipping(
      enabled: true,
      location: nil,
      preference: .restricted,
      summary: "Ships to Australia",
      type: nil
    )
    |> Reward.lens.shippingRulesExpanded .~ [
      ShippingRule(
        cost: 10,
        id: 0,
        location: Location.australia,
        estimatedMin: nil,
        estimatedMax: nil
      )
    ]
    |> Reward.lens.limit .~ 5
    |> Reward.lens.remaining .~ 5
    |> Reward.lens.isAvailable .~ true

  internal static let digitalReward = Reward.template
    |> Reward.lens.title .~ "Digital item"
    |> Reward.lens.shipping .~ Reward.Shipping(
      enabled: false,
      location: nil,
      preference: Reward.Shipping.Preference.none,
      summary: "Digital thing",
      type: .noShipping
    )
    |> Reward.lens.limit .~ 5
    |> Reward.lens.remaining .~ 5
    |> Reward.lens.isAvailable .~ true

  internal static let localShippingReward = Reward.template
    |> Reward.lens.title .~ "Ships locally"
    |> Reward.lens.shipping .~ Reward.Shipping(
      enabled: false,
      location: Reward.Shipping.Location(
        id: 0,
        localizedName: "My house"
      ),
      preference: Reward.Shipping.Preference.local,
      summary: "Pick up at my hosue",
      type: nil
    )
    |> Reward.lens.localPickup .~ Location.usa
    |> Reward.lens.limit .~ 5
    |> Reward.lens.remaining .~ 5
    |> Reward.lens.isAvailable .~ true
}
