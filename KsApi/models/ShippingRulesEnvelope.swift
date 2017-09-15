import Argo
import Curry
import Runes

public struct ShippingRulesEnvelope {
  public fileprivate(set) var shippingRules: [ShippingRule]
}

extension ShippingRulesEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ShippingRulesEnvelope> {
    return curry(ShippingRulesEnvelope.init)
      <^> json <|| "shipping_rules"
  }
}
