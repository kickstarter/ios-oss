import Foundation

public extension ShippingRule {
  static func shippingRule(from backing: ManagePledgeViewBackingEnvelope.Backing) -> ShippingRule? {
    guard
      let location = backing.location,
      let locationId = decompose(id: location.id),
      let shippingAmount = backing.shippingAmount?.amount
    else { return nil }

    /**
     The shipping amount is returned as the total for the reward and add-ons,
     for this to make sense in the rest of the app we need to reverse this back to
     what it would be as an individual shipping cost.
     Apologies for any inconvenience this may cause.
     */
    let addOns = backing.addOns?.nodes ?? []
    let shippingRewardsCount = backing.reward?.shippingPreference == .noShipping ? 0 : 1
      + addOns.reduce(0) { accum, addOn in accum + (addOn.shippingPreference == .noShipping ? 0 : 1) }

    let shippingRuleCost = shippingRewardsCount > 0 ? NSDecimalNumber(value: shippingAmount)
      .dividing(by: NSDecimalNumber(value: shippingRewardsCount))
      .doubleValue : 0

    return ShippingRule(
      cost: shippingRuleCost,
      id: nil,
      location: Location(
        country: location.country,
        displayableName: location.displayableName,
        id: locationId,
        localizedName: location.countryName,
        name: location.name
      )
    )
  }
}
