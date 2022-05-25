import Foundation
import Prelude

extension Reward {
  public enum lens {
    public static let backersCount = Lens<Reward, Int?>(
      view: { $0.backersCount },
      set: { Reward(
        backersCount: $0,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let localPickup = Lens<Reward, Location?>(
      view: { $0.localPickup },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $0
      ) }
    )

    public static let convertedMinimum = Lens<Reward, Double>(
      view: { $0.convertedMinimum },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $0,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let description = Lens<Reward, String>(
      view: { $0.description },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $0,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let endsAt = Lens<Reward, TimeInterval?>(
      view: { $0.endsAt },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $0,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let estimatedDeliveryOn = Lens<Reward, TimeInterval?>(
      view: { $0.estimatedDeliveryOn },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $0,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let hasAddOns = Lens<Reward, Bool>(
      view: { $0.hasAddOns },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $0,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let id = Lens<Reward, Int>(
      view: { $0.id },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $0,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let limit = Lens<Reward, Int?>(
      view: { $0.limit },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $0,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let limitPerBacker = Lens<Reward, Int?>(
      view: { $0.limitPerBacker },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $0,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let minimum = Lens<Reward, Double>(
      view: { $0.minimum },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $0,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let remaining = Lens<Reward, Int?>(
      view: { $0.remaining },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $0,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let rewardsItems = Lens<Reward, [RewardsItem]>(
      view: { $0.rewardsItems },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $0,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let shipping = Lens<Reward, Reward.Shipping>(
      view: { $0.shipping },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $0,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let shippingRules = Lens<Reward, [ShippingRule]?>(
      view: { $0.shippingRules },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $0,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let shippingRulesExpanded = Lens<Reward, [ShippingRule]?>(
      view: { $0.shippingRulesExpanded },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $0,
        startsAt: $1.startsAt,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let startsAt = Lens<Reward, TimeInterval?>(
      view: { $0.startsAt },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $0,
        title: $1.title,
        localPickup: $1.localPickup
      ) }
    )

    public static let title = Lens<Reward, String?>(
      view: { $0.title },
      set: { Reward(
        backersCount: $1.backersCount,
        convertedMinimum: $1.convertedMinimum,
        description: $1.description,
        endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn,
        hasAddOns: $1.hasAddOns,
        id: $1.id,
        limit: $1.limit,
        limitPerBacker: $1.limitPerBacker,
        minimum: $1.minimum,
        remaining: $1.remaining,
        rewardsItems: $1.rewardsItems,
        shipping: $1.shipping,
        shippingRules: $1.shippingRules,
        shippingRulesExpanded: $1.shippingRulesExpanded,
        startsAt: $1.startsAt,
        title: $0,
        localPickup: $1.localPickup
      ) }
    )
  }
}

extension Lens where Whole == Reward, Part == Reward.Shipping {
  public var enabled: Lens<Reward, Bool> {
    return Reward.lens.shipping .. Reward.Shipping.lens.enabled
  }

  public var preference: Lens<Reward, Reward.Shipping.Preference?> {
    return Reward.lens.shipping .. Reward.Shipping.lens.preference
  }

  public var summary: Lens<Reward, String?> {
    return Reward.lens.shipping .. Reward.Shipping.lens.summary
  }
}
