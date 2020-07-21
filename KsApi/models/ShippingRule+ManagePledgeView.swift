import Foundation

public extension ShippingRule {
  static func shippingRule(from backing: ManagePledgeViewBackingEnvelope.Backing) -> ShippingRule? {
    guard
      let location = backing.location,
      let locationId = decompose(id: location.id),
      let shippingAmount = backing.shippingAmount?.amount
    else { return nil }

    return ShippingRule(
      cost: shippingAmount,
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
