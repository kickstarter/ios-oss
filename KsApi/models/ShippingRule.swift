import Argo
import Curry
import Runes

public struct ShippingRule: Equatable {
  public let cost: Double
  public let id: Int?
  public let location: Location
}

extension ShippingRule: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ShippingRule> {
    return curry(ShippingRule.init)
      <^> (json <| "cost" >>- stringToDouble)
      <*> json <|? "id"
      <*> json <| "location"
  }
}

private func stringToDouble(_ string: String) -> Decoded<Double> {
  return Double(string).map(Decoded.success) ?? .success(0)
}
