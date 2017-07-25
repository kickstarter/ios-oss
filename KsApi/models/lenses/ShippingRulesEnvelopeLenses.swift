import Prelude

extension ShippingRulesEnvelope {
  public enum lens {
    public static let shippingRules = Lens<ShippingRulesEnvelope, [ShippingRule]>(
      view: { $0.shippingRules },
      set: { shippingRules, _ in .init(shippingRules: shippingRules) }
    )
  }
}
