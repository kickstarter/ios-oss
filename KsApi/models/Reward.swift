import Foundation
import Prelude

public struct Reward {
  public let backersCount: Int?
  public let convertedMinimum: Double
  public let description: String
  public let endsAt: TimeInterval?
  public let estimatedDeliveryOn: TimeInterval?
  public let hasAddOns: Bool
  public let id: Int
  public let latePledgeAmount: Double
  public let limit: Int?
  public let limitPerBacker: Int?
  public let minimum: Double
  public let pledgeAmount: Double
  public let postCampaignPledgingEnabled: Bool
  public let remaining: Int?
  public let rewardsItems: [RewardsItem]
  public let shipping: Shipping // only v1
  public let shippingRules: [ShippingRule]? // only GraphQL
  public let shippingRulesExpanded: [ShippingRule]? // only GraphQL
  public let startsAt: TimeInterval?
  public let title: String?
  public let localPickup: Location?
  /// isAvailable is provided by GraphQL but not by API V1.
  public let isAvailable: Bool?
  /// The URL of the reward image retrieved from GraphQL.
  /// - Source: `Reward.image.url`
  public let image: Image?

  /// Returns `true` is this is the "fake" "No reward" reward.
  public var isNoReward: Bool {
    return self.id == Reward.noReward.id
  }

  /// Returns `true` if the `Reward` has a value for the `limit` property.
  public var isLimitedQuantity: Bool {
    return self.limit != nil
  }

  /// Returns `true` if the `Reward` has a value for the `endsAt` property.
  public var isLimitedTime: Bool {
    return self.endsAt != nil
  }

  public var isRestrictedShippingPreference: Bool {
    return self.shipping.preference == .restricted
  }

  public var isUnRestrictedShippingPreference: Bool {
    return self.shipping.preference == .unrestricted
  }

  public var isLocalShippingPreference: Bool {
    return self.shipping.preference == .local
  }

  public var hasNoShippingPreference: Bool {
    return self.shipping.preference == Reward.Shipping.Preference.none
  }

  /**
   Returns the closest matching `ShippingRule` for this `Reward` to `otherShippingRule`.
   If no match is found `otherShippingRule` is returned, this is to be backward-compatible
   with v1 Rewards that do not include the `shippingRulesExpanded` array.
   */
  public func shippingRule(matching otherShippingRule: ShippingRule?) -> ShippingRule? {
    return self.shippingRulesExpanded?
      .first { shippingRule in
        shippingRule.location.id == otherShippingRule?.location.id
      }
      ?? otherShippingRule
  }

  public struct Shipping: Decodable {
    public let enabled: Bool
    public let location: Location? /// via v1 if `ShippingType` is `singleLocation`
    public let preference: Preference?
    public let summary: String?
    public let type: ShippingType?

    public struct Location: Equatable, Decodable {
      private enum CodingKeys: String, CodingKey {
        case id
        case localizedName = "localized_name"
      }

      public let id: Int
      public let localizedName: String
    }

    public enum Preference: String, Decodable {
      case local
      case none
      case restricted
      case unrestricted
    }

    public enum ShippingType: String, Decodable {
      case anywhere
      case multipleLocations = "multiple_locations"
      case noShipping = "no_shipping"
      case singleLocation = "single_location"
    }
  }
  
  public struct Image {
    /// Alt text on the image
    public let altText: String
    /// URL of the image
    public let url: String?
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

extension Reward: Decodable {
  enum CodingKeys: String, CodingKey {
    case backersCount = "backers_count"
    case convertedMinimum = "converted_minimum"
    case description
    case reward
    case endsAt = "ends_at"
    case estimatedDeliveryOn = "estimated_delivery_on"
    case hasAddOns = "has_addons"
    case id
    case latePledgeAmount
    case limit
    case limitPerBacker = "limit_per_backer"
    case minimum
    case pledgeAmount
    case postCampaignPledgingEnabled = "post_campaign_pledging_enabled"
    case remaining
    case rewardsItems = "rewards_items"
    case shippingRules = "shipping_rules"
    case shippingRulesExpanded = "shipping_rules_expanded"
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
    self.latePledgeAmount = try values.decodeIfPresent(Double.self, forKey: .latePledgeAmount) ?? 0
    self.limit = try values.decodeIfPresent(Int.self, forKey: .limit)
    self.limitPerBacker = try values.decodeIfPresent(Int.self, forKey: .limitPerBacker)
    self.minimum = try values.decode(Double.self, forKey: .minimum)
    self.pledgeAmount = try values.decodeIfPresent(Double.self, forKey: .pledgeAmount) ?? 0
    self.postCampaignPledgingEnabled =
      try values.decodeIfPresent(Bool.self, forKey: .postCampaignPledgingEnabled) ?? false
    self.remaining = try values.decodeIfPresent(Int.self, forKey: .remaining)
    self.rewardsItems = try values.decodeIfPresent([RewardsItem].self, forKey: .rewardsItems) ?? []
    self.shipping = try Shipping(from: decoder)
    self.shippingRules = try values.decodeIfPresent([ShippingRule].self, forKey: .shippingRules) ?? []
    self.shippingRulesExpanded = try values.decodeIfPresent(
      [ShippingRule].self,
      forKey: .shippingRulesExpanded
    ) ?? []
    self.startsAt = try values.decodeIfPresent(TimeInterval.self, forKey: .startsAt)
    self.title = try values.decodeIfPresent(String.self, forKey: .title)
    // NOTE: `v1` is deprecated and doesn't contain any location pickup information.
    self.localPickup = nil
    self.isAvailable = nil
    self.image = nil
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
