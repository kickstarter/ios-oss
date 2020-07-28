extension RewardAddOnSelectionViewEnvelope {
  static var template: RewardAddOnSelectionViewEnvelope {
    return RewardAddOnSelectionViewEnvelope(
      project: .init(
        actions: .init(displayConvertAmount: false),
        addOns: .template,
        pid: 123,
        fxRate: 1.002
      )
    )
  }
}

extension RewardAddOnSelectionViewEnvelope.Project.AddOns {
  static let template = RewardAddOnSelectionViewEnvelope.Project.AddOns(nodes: [.template])
}

extension RewardAddOnSelectionViewEnvelope.Project.Reward {
  static let template = RewardAddOnSelectionViewEnvelope.Project.Reward(
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
    startsAt: 1_487_502_131
  )
}

extension RewardAddOnSelectionViewEnvelope.Project.Reward.ShippingRule.Location {
  static let template = RewardAddOnSelectionViewEnvelope.Project.Reward.ShippingRule.Location(
    country: "CA",
    countryName: "Canada",
    displayableName: "Canada",
    id: "TG9jYXRpb24tMjM0MjQ3NzU=",
    name: "Canada"
  )
}

extension RewardAddOnSelectionViewEnvelope.Project.Reward.ShippingRule {
  static let template = RewardAddOnSelectionViewEnvelope.Project.Reward.ShippingRule(
    cost: Money(amount: 10, currency: .usd, symbol: "$"),
    id: "U2hpcHBpbmdSdWxlLTEwMzc5NTgz",
    location: .template
  )
}
