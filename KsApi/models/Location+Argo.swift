import Argo
import Curry
import Runes

extension Location: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Location> {
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
