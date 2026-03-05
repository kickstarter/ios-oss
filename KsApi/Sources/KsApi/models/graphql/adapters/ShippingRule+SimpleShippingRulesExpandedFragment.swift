import GraphAPI

extension ShippingRule {
  // These shipping rules are constructed from simplified versions of the shipping rules.
  // They are expanded (i.e. EU -> Austria, Belgium, ...) to include all shippable countries.
  // They contain the data we need to calculate shipping, just in a different initial format.
  static func simpleShippingRulesExpanded(
    from fragment: GraphAPI.SimpleShippingRulesExpandedFragment
  ) -> [ShippingRule] {
    return fragment.simpleShippingRulesExpanded
      .compactMap { node -> ShippingRule? in
        self.shippingRule(from: node)
      }
  }

  internal static func shippingRule(
    from node: SimpleShippingRulesExpandedFragment.SimpleShippingRulesExpanded?
  ) -> ShippingRule? {
    guard let node,
          let idString = node.locationId,
          let locationId = decompose(id: idString),
          let name = node.locationName,
          let cost = node.cost.flatMap(Double.init)
    else {
      return nil
    }

    let location = Location(
      country: node.country,
      displayableName: name,
      id: locationId,
      localizedName: name,
      name: name
    )

    let currency = node.currency.flatMap { Money.CurrencyCode(rawValue: $0) }
    let estimatedMin = node.estimatedMin.flatMap(Double.init)
      .flatMap { Money(amount: $0, currency: currency) }
    let estimatedMax = node.estimatedMax.flatMap(Double.init)
      .flatMap { Money(amount: $0, currency: currency) }

    return ShippingRule(
      cost: cost,
      id: nil,
      location: location,
      estimatedMin: estimatedMin,
      estimatedMax: estimatedMax
    )
  }
}
