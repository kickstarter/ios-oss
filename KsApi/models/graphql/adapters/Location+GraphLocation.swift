import Foundation

/**
 Returns a minimal `Location` from a `GraphLocation`
 */
extension Location {
  static func location(from graphLocation: GraphLocation) -> Location? {
    guard let id = decompose(id: graphLocation.id) else { return nil }

    return Location(
      country: graphLocation.country,
      displayableName: graphLocation.displayableName,
      id: id,
      localizedName: graphLocation.name,
      name: graphLocation.name
    )
  }
}
