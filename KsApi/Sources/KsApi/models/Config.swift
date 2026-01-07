public enum Experiment {
  public enum Name: String {
    case creatorsNameDiscovery = "show_created_by_discovery"

    public var debugDefault: Bool {
      switch self {
      case .creatorsNameDiscovery: return true
      }
    }
  }

  public enum Variant: String {
    case control // default
    case experimental
  }
}

public typealias Features = [String: Bool]

public struct Config {
  public var abExperiments: [String: String]
  public var appId: Int
  public var applePayCountries: [String]
  public var countryCode: String
  public var features: Features
  public var iTunesLink: String
  public var launchedCountries: [Project.Country]
  public var locale: String
  public var stripePublishableKey: String

  public var abExperimentsArray: [String] {
    let stringsArray = self.abExperiments.map { key, value in
      key + "[\(value)]"
    }
    return stringsArray
  }
}

extension Config: Decodable {
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
    self.stripePublishableKey = try values
      .nestedContainer(keyedBy: CodingKeys.StripeCodingKeys.self, forKey: .stripe)
      .decode(String.self, forKey: .stripePublishableKey)
  }
}

extension Config: Equatable {}

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
