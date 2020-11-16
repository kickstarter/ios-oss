import Foundation
import Prelude

struct GraphLocation: Decodable {
  var country: String
  var countryName: String?
  var displayableName: String
  var id: String
  var name: String
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
