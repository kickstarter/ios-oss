import Foundation

extension GraphReward {
  static let template = GraphReward(
    amount: Money(amount: 159.0, currency: .usd, symbol: "$"),
    backersCount: 55,
    convertedAmount: Money(amount: 180.0, currency: .usd, symbol: "$"),
    description: "Description",
    displayName: "Display Name",
    endsAt: 1_887_502_131,
    estimatedDeliveryOn: "2020-08-01",
    id: "UmV3YXJkLTE=",
    isMaxPledge: false,
    items: Items(nodes: [
      .init(id: "UmV3YXJkSXRlbS05MjEwOTU=", name: "Item 1"),
      .init(id: "UmV3YXJkSXRlbS05MjEwOTM=", name: "Item 2")
    ]),
    limit: 5,
    name: "Reward name",
    remainingQuantity: 10,
    shippingPreference: .restricted,
    shippingRules: [.template],
    shippingRulesExpanded: ShippingRuleExpanded(nodes: [.template]),
    startsAt: 1_487_502_131
  )
}

extension GraphReward.ShippingRule {
  static let template = GraphReward.ShippingRule(
    cost: Money(amount: 10, currency: .usd, symbol: "$"),
    id: "U2hpcHBpbmdSdWxlLTEwMzc5NTgz",
    location: .template
  )
}
