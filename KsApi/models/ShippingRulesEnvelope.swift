import Curry
import Runes

public struct ShippingRulesEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case shippingRules = "shipping_rules"
  }

  public let shippingRules: [ShippingRule]
}
