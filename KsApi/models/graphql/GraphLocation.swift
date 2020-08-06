import Foundation
import Prelude

public struct GraphLocation: Swift.Decodable {
  public var country: String
  public var countryName: String
  public var displayableName: String
  public var id: String
  public var name: String
}

extension GraphLocation {
  /// All properties required to instantiate a `Location` via a `GraphLocation`
  static var baseQueryProperties: NonEmptySet<Query.Location> {
    return Query.Location.id +| [
      .country,
      .countryName,
      .displayableName,
      .name
    ]
  }
}
