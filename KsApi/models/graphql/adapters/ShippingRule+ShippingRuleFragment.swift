import Foundation

extension ShippingRule {
  /**
   Returns a minimal `ShippingRule` from a `ShippingRuleFragment`
   */
  static func shippingRule(from shippingRuleFragment: GraphAPI.ShippingRuleFragment) -> ShippingRule? {
    guard
      let locationFragment = shippingRuleFragment.location?.fragments.locationFragment,
      let location = Location.location(from: locationFragment)
    else { return nil }

    return ShippingRule(
      cost: shippingRuleFragment.cost?.fragments.moneyFragment.amount.flatMap(Double.init) ?? 0,
      id: decompose(id: shippingRuleFragment.id),
      location: location
    )
  }
}
