import Foundation
import Prelude

public struct GraphReward: Swift.Decodable {
  public var amount: Money
  public var backersCount: Int
  public var convertedAmount: Money
  public var description: String
  public var displayName: String
  public var endsAt: TimeInterval?
  public var estimatedDeliveryOn: String?
  public var id: String
  public var isMaxPledge: Bool
  public var items: Items?
  public var limit: Int?
  public var limitPerBacker: Int?
  public var name: String
  public var remainingQuantity: Int?
  public var shippingPreference: ShippingPreference?
  public var shippingRules: [ShippingRule]?
  public var startsAt: TimeInterval?

  public struct Items: Swift.Decodable {
    public let nodes: [Item]

    public struct Item: Swift.Decodable {
      public var id: String
      public var name: String
    }
  }

  // TODO: Extract to global scope as `GraphShippingPreference` when needed.
  public enum ShippingPreference: String, Swift.Decodable {
    case noShipping = "none"
    case restricted
    case unrestricted
  }

  // TODO: Extract to global scope as `GraphShippingRule` when needed.
  public struct ShippingRule: Swift.Decodable {
    public var cost: Money
    public var id: String
    public var location: GraphLocation

    public struct Location: Swift.Decodable {
      public var country: String
      public var countryName: String
      public var displayableName: String
      public var id: String
      public var name: String
    }
  }
}

extension GraphReward {
  /// All properties required to instantiate a `Reward` via a `GraphReward`
  static var baseQueryProperties: NonEmptySet<Query.Reward> {
    return Query.Reward.id +| [
      .id,
      .displayName,
      .description,
      .estimatedDeliveryOn,
      .name,
      .amount(Money.baseQueryProperties),
      .convertedAmount(Money.baseQueryProperties),
      .backersCount,
      .isMaxPledge,
      .limit,
      .limitPerBacker,
      .items([], NonEmptySet(.nodes(.id +| [.name]))),
      .remainingQuantity,
      .shippingPreference,
      .shippingRules(.id +| [
        .cost(Money.baseQueryProperties),
        .location(GraphLocation.baseQueryProperties)
      ]),
      .startsAt,
      .endsAt
    ]
  }
}
