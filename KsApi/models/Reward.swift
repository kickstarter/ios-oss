import Argo
import Curry
import Prelude
import Runes

public struct Reward {
  public let backersCount: Int?
  public let convertedMinimum: Double
  public let description: String
  public let endsAt: TimeInterval?
  public let estimatedDeliveryOn: TimeInterval?
  public let id: Int
  public let limit: Int?
  public let minimum: Double
  public let remaining: Int?
  public let rewardsItems: [RewardsItem]
  public let shipping: Shipping
  public let startsAt: TimeInterval?
  public let title: String?

  /// Returns `true` is this is the "fake" "No reward" reward.
  public var isNoReward: Bool {
    return self.id == Reward.noReward.id
  }

  public struct Shipping: Swift.Decodable {
    public let enabled: Bool
    public let location: Location?
    public let preference: Preference?
    public let summary: String?
    public let type: ShippingType?

    public struct Location: Equatable, Swift.Decodable {
      private enum CodingKeys: String, CodingKey {
        case id
        case localizedName = "localized_name"
      }

      public let id: Int
      public let localizedName: String
    }

    public enum Preference: String, Swift.Decodable {
      case none
      case restricted
      case unrestricted
    }

    public enum ShippingType: String, Swift.Decodable {
      case anywhere
      case multipleLocations = "multiple_locations"
      case noShipping = "no_shipping"
      case singleLocation = "single_location"
    }
  }
}

extension Reward: Equatable {}
public func == (lhs: Reward, rhs: Reward) -> Bool {
  return lhs.id == rhs.id
}

private let minimumAndIdComparator = Reward.lens.minimum.comparator <> Reward.lens.id.comparator

extension Reward: Comparable {}
public func < (lhs: Reward, rhs: Reward) -> Bool {
  return minimumAndIdComparator.isOrdered(lhs, rhs)
}

extension Reward: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Reward> {
    let tmp1 = curry(Reward.init)
      <^> json <|? "backers_count"
      <*> json <| "converted_minimum"
      <*> (json <| "description" <|> json <| "reward")
      <*> json <|? "ends_at"
      <*> json <|? "estimated_delivery_on"
    let tmp2 = tmp1
      <*> json <| "id"
      <*> json <|? "limit"
      <*> json <| "minimum"
      <*> json <|? "remaining"
    return tmp2
      <*> ((json <|| "rewards_items") <|> .success([]))
      <*> tryDecodable(json)
      <*> json <|? "starts_at"
      <*> json <|? "title"
  }
}

extension Reward.Shipping {
  private enum CodingKeys: String, CodingKey {
    case enabled = "shipping_enabled"
    case location = "shipping_single_location"
    case preference = "shipping_preference"
    case summary = "shipping_summary"
    case type = "shipping_type"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    self.enabled = try values.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
    self.location = try? values.decode(Location.self, forKey: .location)
    self.preference = try? values.decode(Preference.self, forKey: .preference)
    self.summary = try? values.decode(String.self, forKey: .summary)
    self.type = try? values.decode(ShippingType.self, forKey: .type)
  }
}

extension Reward: GraphIDBridging {
  public static var modelName: String {
    return "Reward"
  }
}
