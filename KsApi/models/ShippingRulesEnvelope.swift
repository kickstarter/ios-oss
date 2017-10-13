import Argo
import Curry
import Runes

public struct ShippingRulesEnvelope {
  public let shippingRules: [ShippingRule]
}

extension ShippingRulesEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ShippingRulesEnvelope> {
    return curry(ShippingRulesEnvelope.init)
      <^> json <|| "shipping_rules"
  }
}
