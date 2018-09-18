import Prelude

extension Reward {
  public enum lens {
    public static let backersCount = Lens<Reward, Int?>(
      view: { $0.backersCount },
      set: { Reward(backersCount: $0, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let description = Lens<Reward, String>(
      view: { $0.description },
      set: { Reward(backersCount: $1.backersCount, description: $0, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let endsAt = Lens<Reward, TimeInterval?>(
      view: { $0.endsAt },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $0,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let estimatedDeliveryOn = Lens<Reward, TimeInterval?>(
      view: { $0.estimatedDeliveryOn },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $0, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let id = Lens<Reward, Int>(
      view: { $0.id },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $0, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let limit = Lens<Reward, Int?>(
      view: { $0.limit },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $0, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let minimum = Lens<Reward, Double>(
      view: { $0.minimum },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $0,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let remaining = Lens<Reward, Int?>(
      view: { $0.remaining },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $0, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let rewardsItems = Lens<Reward, [RewardsItem]>(
      view: { $0.rewardsItems },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $0, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let shipping = Lens<Reward, Reward.Shipping>(
      view: { $0.shipping },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $0, startsAt: $1.startsAt,
        title: $1.title) }
    )

    public static let startsAt = Lens<Reward, TimeInterval?>(
      view: { $0.startsAt },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $0,
        title: $1.title) }
    )

    public static let title = Lens<Reward, String?>(
      view: { $0.title },
      set: { Reward(backersCount: $1.backersCount, description: $1.description, endsAt: $1.endsAt,
        estimatedDeliveryOn: $1.estimatedDeliveryOn, id: $1.id, limit: $1.limit, minimum: $1.minimum,
        remaining: $1.remaining, rewardsItems: $1.rewardsItems, shipping: $1.shipping, startsAt: $1.startsAt,
        title: $0) }
    )
  }
}

extension Lens where Whole == Reward, Part == Reward.Shipping {
  public var enabled: Lens<Reward, Bool> {
    return Reward.lens.shipping..Reward.Shipping.lens.enabled
  }

  public var preference: Lens<Reward, Reward.Shipping.Preference?> {
    return Reward.lens.shipping..Reward.Shipping.lens.preference
  }

  public var summary: Lens<Reward, String?> {
    return Reward.lens.shipping..Reward.Shipping.lens.summary
  }
}
