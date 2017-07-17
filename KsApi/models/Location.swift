import Argo
import Curry
import Runes

public struct Location {
  public let country: String
  public let displayableName: String
  public let id: Int
  public let name: String

  public static let none = Location(country: "", displayableName: "", id: -42, name: "")
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
      <*> json <| "name"
  }
}

extension Location: EncodableType {
  public func encode() -> [String:Any] {
    var result: [String:Any] = [:]
    result["country"] = self.country
    result["displayable_name"] = self.displayableName
    result["id"] = self.id
    result["name"] = self.name
    return result
  }
}
