import Argo
import Curry
import Runes

public struct Location {
  public let country: String
  public let displayableName: String
  public let id: Int
  public let localizedName: String
  public let name: String

  public static let none = Location(country: "", displayableName: "", id: -42, localizedName: "", name: "")
}

extension Location: Swift.Decodable {

  enum CodingKeys: String, CodingKey {
    case country, displayableName = "displayable_name", id, localizedName = "localized_name", name
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

extension Location: Argo.Decodable {
  static public func decode(_ json: JSON) -> Decoded<Location> {
    return curry(Location.init)
      <^> json <| "country"
      <*> json <| "displayable_name"
      <*> json <| "id"
      <*> json <| "localized_name"
      <*> json <| "name"
  }
}

extension Location: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["country"] = self.country
    result["displayable_name"] = self.displayableName
    result["id"] = self.id
    result["localized_name"] = self.localizedName
    result["name"] = self.name
    return result
  }
}
