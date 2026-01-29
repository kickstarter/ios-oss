

public struct ShippingRulesEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case shippingRules = "shipping_rules"
  }

  public let shippingRules: [ShippingRule]
}
