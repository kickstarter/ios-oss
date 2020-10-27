import Curry
import Runes

public struct ShippingRulesEnvelope: Swift.Decodable {
  public let shippingRules: [ShippingRule]
}

/*
 extension ShippingRulesEnvelope: Decodable {
 public static func decode(_ json: JSON) -> Decoded<ShippingRulesEnvelope> {
   return curry(ShippingRulesEnvelope.init)
     <^> json <|| "shipping_rules"
 }
 }
 */
