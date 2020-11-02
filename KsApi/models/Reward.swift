import Curry
import Prelude
import Runes

public struct Reward {
  public let backersCount: Int?
  public let convertedMinimum: Double
  public let description: String
  public let endsAt: TimeInterval?
  public let estimatedDeliveryOn: TimeInterval?
  public let hasAddOns: Bool
  public let id: Int
  public let limit: Int?
  public let limitPerBacker: Int?
  public let minimum: Double
  public let remaining: Int?
  public let rewardsItems: [RewardsItem]
  public let shipping: Shipping // only v1
  public let shippingRules: [ShippingRule]? // only GraphQL
  public let startsAt: TimeInterval?
  public let title: String?

  /// Returns `true` is this is the "fake" "No reward" reward.
  public var isNoReward: Bool {
    return self.id == Reward.noReward.id
  }

  /**
   Returns the closest matching `ShippingRule` for this `Reward` to `otherShippingRule`.
   If no match is found `otherShippingRule` is returned, this is to be backward-compatible
   with v1 Rewards that do not include the `shippingRules` array.
   */
  public func shippingRule(matching otherShippingRule: ShippingRule?) -> ShippingRule? {
    return self.shippingRules?
      .first { shippingRule in shippingRule.location.id == otherShippingRule?.location.id }
      ?? otherShippingRule
  }

  public struct Shipping: Swift.Decodable {
    public let enabled: Bool
    public let location: Location? /// via v1 if `ShippingType` is `singleLocation`
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

extension Reward: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case backersCount = "backers_count"
    case convertedMinimum = "converted_minimum"
    case description
    case reward
    case endsAt = "ends_at"
    case estimatedDeliveryOn = "estimated_delivery_on"
    case hasAddOns = "has_addons"
    case id
    case limit
    case limitPerBacker = "limit_per_backer"
    case minimum
    case remaining
    case rewardsItems = "rewards_items"
    case shippingRules = "shipping_rules"
    case startsAt = "starts_at"
    case title
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.backersCount = try values.decodeIfPresent(Int.self, forKey: .backersCount)
    self.convertedMinimum = try values.decode(Double.self, forKey: .convertedMinimum)
    if let description = try? values.decode(String.self, forKey: .description) {
      self.description = description
    } else {
      self.description = try values.decode(String.self, forKey: .reward)
    }
    self.endsAt = try values.decodeIfPresent(TimeInterval.self, forKey: .endsAt)
    self.estimatedDeliveryOn = try values.decodeIfPresent(TimeInterval.self, forKey: .estimatedDeliveryOn)
    self.hasAddOns = try values.decodeIfPresent(Bool.self, forKey: .hasAddOns) ?? false
    self.id = try values.decode(Int.self, forKey: .id)
    self.limit = try values.decodeIfPresent(Int.self, forKey: .limit)
    self.limitPerBacker = try values.decodeIfPresent(Int.self, forKey: .limitPerBacker)
    self.minimum = try values.decode(Double.self, forKey: .minimum)
    self.remaining = try values.decodeIfPresent(Int.self, forKey: .remaining)
    self.rewardsItems = try values.decodeIfPresent([RewardsItem].self, forKey: .rewardsItems) ?? []
    self.shipping = try Shipping(from: decoder)
    self.shippingRules = try values.decodeIfPresent([ShippingRule].self, forKey: .shippingRules) ?? []
    self.startsAt = try values.decodeIfPresent(TimeInterval.self, forKey: .startsAt)
    self.title = try values.decodeIfPresent(String.self, forKey: .startsAt)
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
