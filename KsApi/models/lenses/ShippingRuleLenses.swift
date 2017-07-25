import Prelude

extension ShippingRule {
  public enum lens {
    public static let cost = Lens<ShippingRule, Double>(
      view: { $0.cost },
      set: { .init(cost: $0, id: $1.id, location: $1.location) }
    )

    public static let id = Lens<ShippingRule, Int?>(
      view: { $0.id },
      set: { .init(cost: $1.cost, id: $0, location: $1.location) }
    )

    public static let location = Lens<ShippingRule, Location>(
      view: { $0.location },
      set: { .init(cost: $1.cost, id: $1.id, location: $0) }
    )
  }
}
