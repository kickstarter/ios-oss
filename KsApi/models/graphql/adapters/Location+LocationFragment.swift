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
}
