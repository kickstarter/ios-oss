import Argo
import Curry
import Runes

extension Config: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Config> {
    let tmp = curry(Config.init)
      <^> decodeDictionary(json <| "ab_experiments")
      <*> json <| "app_id"
      <*> json <|| "apple_pay_countries"
      <*> json <| "country_code"
      <*> decodeDictionary(json <| "features")
    return tmp
      <*> json <| "itunes_link"
      <*> json <|| "launched_countries"
      <*> json <| "locale"
      <*> json <| ["stripe", "publishable_key"]
  }
}

extension Config: EncodableType {
  public func encode() -> [String: Any] {
    var result: [String: Any] = [:]
    result["ab_experiments"] = self.abExperiments
    result["app_id"] = self.appId
    result["apple_pay_countries"] = self.applePayCountries
    result["country_code"] = self.countryCode
    result["features"] = self.features
    result["itunes_link"] = self.iTunesLink
    result["launched_countries"] = self.launchedCountries.map { $0.encode() }
    result["locale"] = self.locale
    result["stripe"] = ["publishable_key": self.stripePublishableKey]
    return result
  }
}

// Useful for getting around swift optimization bug: https://github.com/thoughtbot/Argo/issues/363
// Turns out using `>>-` or `flatMap` on a `Decoded` fails to compile with optimizations on, so this
// function does it manually.
private func decodeDictionary<T: Argo.Decodable>(_ j: Decoded<JSON>)
  -> Decoded<[String: T]> where T.DecodedType == T {
  switch j {
  case let .success(json): return [String: T].decode(json)
  case let .failure(e): return .failure(e)
  }
}
