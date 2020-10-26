import Curry
import Runes

public struct ShippingRule {
  public let cost: Double
  public let id: Int?
  public let location: Location
}

extension ShippingRule: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case cost = "cost"
    case id = "id"
    case location = "location"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.cost = try Double(values.decode(String.self, forKey: .cost)) ?? 0
    self.id = try values.decodeIfPresent(Int.self, forKey: .id)
    self.location = try values.decode(Location.self, forKey: .location)
  }
}

extension ShippingRule: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ShippingRule> {
    return curry(ShippingRule.init)
      <^> (json <| "cost" >>- stringToDouble)
      <*> json <|? "id"
      <*> json <| "location"
  }
}

extension ShippingRule: Equatable {}
public func == (lhs: ShippingRule, rhs: ShippingRule) -> Bool {
  // TODO: change to compare id once that api is deployed
  return lhs.location == rhs.location
}

private func stringToDouble(_ string: String) -> Decoded<Double> {
  return Double(string).map(Decoded.success) ?? .success(0)
}
