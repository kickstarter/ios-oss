

public struct ShippingRule {
  public let cost: Double
  public let id: Int?
  public let location: Location
  public let estimatedMin: Money?
  public let estimatedMax: Money?

  // TODO: This is a temporary patch to fix the fact that the SimpleShippingRule type is not translated.
  // This (and `localizedLocationNameForCheckout`) can be removed when MBL-2859 is fixed.
  public var overrideLocationLocalizedName: String?

  public var localizedLocationNameForCheckout: String {
    return self.overrideLocationLocalizedName ?? self.location.localizedName
  }
}

extension ShippingRule: Decodable {
  enum CodingKeys: String, CodingKey {
    case cost
    case id
    case location
    case estimatedMin
    case estimatedMax
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.cost = try Double(values.decode(String.self, forKey: .cost)) ?? 0
    self.id = try values.decodeIfPresent(Int.self, forKey: .id)
    self.location = try values.decode(Location.self, forKey: .location)
    self.estimatedMin = try values.decodeIfPresent(Money.self, forKey: .estimatedMin)
    self.estimatedMax = try values.decodeIfPresent(Money.self, forKey: .estimatedMax)
  }
}

extension ShippingRule: Equatable {}
public func == (lhs: ShippingRule, rhs: ShippingRule) -> Bool {
  // TODO: change to compare id once that api is deployed
  return lhs.location == rhs.location
}
