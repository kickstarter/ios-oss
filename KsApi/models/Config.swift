import Argo
import Curry
import Runes

public enum Experiment {

  public enum Name: String {
    case creatorsNameDiscovery = "show_created_by_discovery"
  }

  public enum Variant: String {
    case control //default
    case experimental
  }
}

public struct Config {
  public private(set) var abExperiments: [String: String]
  public private(set) var appId: Int
  public private(set) var applePayCountries: [String]
  public private(set) var countryCode: String
  public private(set) var features: [String: Bool]
  public private(set) var iTunesLink: String
  public private(set) var launchedCountries: [Project.Country]
  public private(set) var locale: String
  public private(set) var stripePublishableKey: String

  public var abExperimentsArray: [String] {
    let stringsArray = self.abExperiments.map { (key, value) in
      key + "[\(value)]"
    }
    return stringsArray
  }
}

extension Config: Swift.Decodable {

  enum CodingKeys: String, CodingKey {
    case abExperiments = "ab_experiments"
    case appId = "app_id"
    case applePayCountries = "apple_pay_countries"
    case countryCode = "country_code"
    case features
    case iTunesLink = "itunes_link"
    case launchedCountries = "launched_countries"
    case locale
    case stripe

    enum StripeCodingKeys: String, CodingKey {
      case stripePublishableKey = "publishable_key"
    }
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.abExperiments = try values.decode([String: String].self, forKey: .abExperiments)
    self.appId = try values.decode(Int.self, forKey: .appId)
    self.applePayCountries = try values.decode([String].self, forKey: .applePayCountries)
    self.countryCode = try values.decode(String.self, forKey: .countryCode)
    self.features = try values.decode([String: Bool].self, forKey: .features)
    self.iTunesLink = try values.decode(String.self, forKey: .iTunesLink)
    self.launchedCountries = try values.decode([Project.Country].self, forKey: .launchedCountries)
    self.locale = try values.decode(String.self, forKey: .locale)

    let stripe = try values.decode([String: String].self, forKey: .stripe)
    if let publicshableKey = stripe["publishable_key"] {
      self.stripePublishableKey = publicshableKey
    } else {
      throw ErrorEnvelope.couldNotDecodeJSON(.missingKey("publishable_key"))
    }
  }
}

extension Config: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Config> {
    let tmp = curry(Config.init)
      <^> (decodeDictionary(json <| "ab_experiments"))
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

extension Config: Equatable {
}
public func == (lhs: Config, rhs: Config) -> Bool {
  return lhs.abExperiments == rhs.abExperiments &&
    lhs.appId == rhs.appId &&
    lhs.applePayCountries == rhs.applePayCountries &&
    lhs.countryCode == rhs.countryCode &&
    lhs.features == rhs.features &&
    lhs.iTunesLink == rhs.iTunesLink &&
    lhs.launchedCountries == rhs.launchedCountries &&
    lhs.locale == rhs.locale &&
    lhs.stripePublishableKey == rhs.stripePublishableKey
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
