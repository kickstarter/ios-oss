import Curry
import Runes

public struct ShippingRulesEnvelope: Swift.Decodable {
  public let shippingRules: [ShippingRule]
}
