import Foundation
import GraphAPI

extension ShippingRule {
  /**
   Returns a minimal `ShippingRule` from a `ShippingRuleFragment`
   */
  static func shippingRule(from shippingRuleFragment: GraphAPI.ShippingRuleFragment) -> ShippingRule? {
    let estimatedMin = shippingRuleFragment.estimatedMin
    let estimatedMax = shippingRuleFragment.estimatedMax

    // ShippingRule.location may be null if a shipping rule is based on shipping zones.
    // However, the apps only ever use *expanded* shipping rules, not raw shipping rules.
    // An expanded shipping rule should never have a null location - even though
    // it uses the same type as an unexpanded ShippingRule.

    guard let locationFragment = shippingRuleFragment.location?.fragments.locationFragment,
          let location = Location.location(from: locationFragment)
    else {
      assert(false, "A shipping rule is missing its location.")
      return nil
    }

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
