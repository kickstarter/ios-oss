import Foundation

extension ShippingRule {
  /**
   Returns a minimal `ShippingRule` from a `ShippingRuleFragment`
   */
  static func shippingRule(from shippingRuleFragment: GraphAPI.ShippingRuleFragment) -> ShippingRule? {
    let locationFragment = shippingRuleFragment.location.fragments.locationFragment
    let estimatedMin = shippingRuleFragment.estimatedMin
    let estimatedMax = shippingRuleFragment.estimatedMax

    guard let location = Location.location(from: locationFragment) else { return nil }

    let estimatedMinMoney = Money.init(
      amount: estimatedMin?.amount.flatMap(Double.init) ?? 0,
      currency: Money.CurrencyCode(rawValue: estimatedMin?.currency?.rawValue ?? "")
    )

    let estimatedMaxMoney = Money.init(
      amount: estimatedMax?.amount.flatMap(Double.init) ?? 0,
      currency: Money.CurrencyCode(rawValue: estimatedMax?.currency?.rawValue ?? "")
    )

    return ShippingRule(
      cost: shippingRuleFragment.cost?.fragments.moneyFragment.amount.flatMap(Double.init) ?? 0,
      id: decompose(id: shippingRuleFragment.id),
      location: location,
      estimatedMin: estimatedMinMoney,
      estimatedMax: estimatedMaxMoney
    )
  }
}
