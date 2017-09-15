import Argo
import Curry
import Runes

public struct ShippingRule {
  public private(set) var cost: Double
  public private(set) var id: Int?
  public private(set) var location: Location
}

extension ShippingRule: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ShippingRule> {
    return curry(ShippingRule.init)
      <^> (json <| "cost" >>- stringToDouble)
      <*> json <|? "id"
      <*> json <| "location"
  }
}

extension ShippingRule: Equatable {}
public func == (lhs: ShippingRule, rhs: ShippingRule) -> Bool {
  // todo: change to compare id once that api is deployed
  return lhs.location ==  rhs.location
}

private func stringToDouble(_ string: String) -> Decoded<Double> {
  return Double(string).map(Decoded.success) ?? .success(0)
}
