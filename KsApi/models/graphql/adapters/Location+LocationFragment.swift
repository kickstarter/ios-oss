import GraphAPI

/**
 Returns a minimal `Location` from a `LocationFragment`
 */
extension Location {
  static func location(from locationFragment: GraphAPI.LocationFragment) -> Location? {
    guard let id = decompose(id: locationFragment.id) else { return nil }

    return Location(
      country: locationFragment.country,
      displayableName: locationFragment.displayableName,
      id: id,
      localizedName: locationFragment.name,
      name: locationFragment.name
    )
  }

  static func location(from rule: GraphAPI.SimpleShippingRuleLocationFragment?) -> Location? {
    guard let rule = rule,
          let name = rule.locationName,
          let graphId = rule.locationId,
          let id = decompose(id: graphId)
    else {
      return nil
    }

    return Location(
      country: rule.country,
      displayableName: name,
      id: id,
      localizedName: name,
      name: name
    )
  }

  public static func locations(from data: GraphAPI.DefaultLocationsQuery.Data) -> [Location] {
    guard let nodes = data.locations?.nodes else {
      return []
    }

    return nodes.compactMap { node in
      guard let fragment = node?.fragments.locationFragment else { return nil }
      return KsApi.Location.location(from: fragment)
    }
  }

  public static func locations(from data: GraphAPI.LocationsByTermQuery.Data) -> [Location] {
    guard let nodes = data.locations?.nodes else {
      return []
    }

    return nodes.compactMap { node in
      guard let fragment = node?.fragments.locationFragment else { return nil }
      return KsApi.Location.location(from: fragment)
    }
  }

  public static func locations(from data: GraphAPI.ShippableLocationsForProjectQuery.Data) -> [Location] {
    let allLocations = allLocations(from: data)
    return self.flattenAndDedupeLocations(from: allLocations)
  }

  static func allLocations(from data: GraphAPI.ShippableLocationsForProjectQuery.Data) -> [[Location]] {
    return data.project?.rewards?.nodes?.compactMap { reward in
      reward?.simpleShippingRulesExpanded.compactMap { rule -> Location? in
        Location.location(from: rule?.fragments.simpleShippingRuleLocationFragment)
      }
    } ?? []
  }

  static func flattenAndDedupeLocations(from rewardLocations: [[Location]]) -> [Location] {
    // Flatten the list of locations from all rewards into one list
    let locations = rewardLocations.reduce(into: []) { partialResults, location in
      partialResults += location
    }

    // ...and then filter out any duplicates
    var filteredLocations: [Location] = []
    var seenLocationIds = Set<Int>()

    for location in locations {
      if seenLocationIds.contains(location.id) {
        continue
      }

      filteredLocations.append(location)
      seenLocationIds.insert(location.id)
    }

    return filteredLocations
  }
}
