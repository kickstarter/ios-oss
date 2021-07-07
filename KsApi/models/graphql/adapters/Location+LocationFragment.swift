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
}
