public struct Location {
  public let country: String
  public let displayableName: String
  public let id: Int
  public let localizedName: String
  public let name: String

  public static let none = Location(country: "", displayableName: "", id: -42, localizedName: "", name: "")
}

extension Location: Decodable {
  enum CodingKeys: String, CodingKey {
    case country
    case displayableName = "displayable_name"
    case id
    case localizedName = "localized_name"
    case name
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.country = try values.decode(String.self, forKey: .country)
    self.displayableName = try values.decode(String.self, forKey: .displayableName)
    self.id = try values.decode(Int.self, forKey: .id)
    self.localizedName = try values.decode(String.self, forKey: .localizedName)
    self.name = try values.decode(String.self, forKey: .name)
  }
}

extension Location: Equatable {}
public func == (lhs: Location, rhs: Location) -> Bool {
  return lhs.id == rhs.id
}

extension Location: GraphIDBridging {
  public static var modelName: String {
    return "Location"
  }
}
