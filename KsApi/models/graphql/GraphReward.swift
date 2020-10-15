import Foundation
import Prelude

struct GraphReward: Swift.Decodable {
  var amount: Money
  var backersCount: Int
  var convertedAmount: Money
  var description: String
  var displayName: String
  var endsAt: TimeInterval?
  var estimatedDeliveryOn: String?
  var id: String
  var isMaxPledge: Bool
  var items: Items?
  var limit: Int?
  var limitPerBacker: Int?
  var name: String
  var remainingQuantity: Int?
  var shippingPreference: ShippingPreference?
  var shippingRules: [ShippingRule]?
  var startsAt: TimeInterval?

  struct Items: Swift.Decodable {
    let nodes: [Item]

    struct Item: Swift.Decodable {
      var id: String
      var name: String
    }
  }

  // TODO: Extract to global scope as `GraphShippingPreference` when needed.
  enum ShippingPreference: String, Swift.Decodable {
    case noShipping = "none"
    case restricted
    case unrestricted
  }

  // TODO: Extract to global scope as `GraphShippingRule` when needed.
  struct ShippingRule: Swift.Decodable {
    var cost: Money
    var id: String
    var location: GraphLocation

    struct Location: Swift.Decodable {
      var country: String
      var countryName: String
      var displayableName: String
      var id: String
      var name: String
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
      .shippingRulesExpanded(
        [],
        NonEmptySet(.nodes(.id +|
            [.cost(Money.baseQueryProperties), .location(GraphLocation.baseQueryProperties)]))
      ),
      .startsAt,
      .endsAt
    ]
  }
}
