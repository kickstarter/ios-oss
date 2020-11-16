import Foundation
import Prelude

struct GraphReward: Decodable {
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
  var shippingRulesExpanded: ShippingRuleExpanded?
  var startsAt: TimeInterval?

  struct Items: Decodable {
    let nodes: [Item]

    struct Item: Decodable {
      var id: String
      var name: String
    }
  }

  // TODO: Extract to global scope as `GraphShippingPreference` when needed.
  enum ShippingPreference: String, Decodable {
    case noShipping = "none"
    case restricted
    case unrestricted
  }

  // TODO: Extract to global scope as `GraphShippingRule` when needed.
  struct ShippingRule: Decodable {
    var cost: Money
    var id: String
    var location: GraphLocation

    struct Location: Decodable {
      var country: String
      var countryName: String
      var displayableName: String
      var id: String
      var name: String
    }
  }

  struct ShippingRuleExpanded: Decodable {
    let nodes: [ShippingRule]
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
