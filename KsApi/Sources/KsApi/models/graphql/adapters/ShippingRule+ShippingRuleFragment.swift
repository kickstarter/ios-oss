import Foundation
import GraphAPI

extension ShippingRule {
  /**
   Returns a minimal `ShippingRule` from a `ShippingRuleFragment`
   */
  static func shippingRule(from shippingRuleFragment: GraphAPI.ShippingRuleFragment) -> ShippingRule? {
    let estimatedMin = shippingRuleFragment.estimatedMin
    let estimatedMax = shippingRuleFragment.estimatedMax

    // TODO(CHECK-356): ShippingRule.location is now nullable.
    // The app will be updated to handle this.
    // This is a temporary fix so that we can update the GraphQL schema and un-stick our app builds.
    let location: Location?
    if let locationFragment = shippingRuleFragment.location?.fragments.locationFragment {
      location = Location.location(from: locationFragment)
    } else {
      assert(false, "Created a placeholder location.")
      location = Location(
        country: "",
        displayableName: "",
        id: -9_999,
        localizedName: "",
        name: ""
      )
    }

    guard let location else { return nil }

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
