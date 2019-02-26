import Argo
import Curry
import Runes

extension Project.Country: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Country> {
    let tmp = curry(Project.Country.init)
      <^> (json <| "country" <|> json <| "name")
      <*> (json <| "currency" <|> json <| "currency_code")
      <*> json <| "currency_symbol"
    return tmp
      <*> json <|? "max_pledge"
      <*> json <|? "min_pledge"
      <*> (json <| "currency_trailing_code" <|> json <| "trailing_code")
  }
}

extension Project.Country: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["country"] = self.countryCode
    result["currency"] = self.currencyCode
    result["currency_symbol"] = self.currencySymbol
    result["currency_trailing_code"] = self.trailingCode
    return result
  }
}
