import Argo
import Curry
import Runes

extension Project {
  public struct Country {
    public let countryCode: String
    public let currencyCode: String
    public let currencySymbol: String
    public let maxPledge: Int?
    public let minPledge: Int?
    public let trailingCode: Bool

    // swiftlint:disable line_length
    // swiftlint:disable comma
    public static let AU = Country(countryCode: "AU", currencyCode: "AUD", currencySymbol: "$",  maxPledge: 7_000, minPledge: 1, trailingCode: true)
    public static let AT = Country(countryCode: "AT", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 8_000, minPledge: 1, trailingCode: false)
    public static let BE = Country(countryCode: "BE", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let CA = Country(countryCode: "CA", currencyCode: "CAD", currencySymbol: "$",  maxPledge: 8_000, minPledge: 1, trailingCode: true)
    public static let CH = Country(countryCode: "CH", currencyCode: "CHF", currencySymbol: "Fr", maxPledge: 7_000, minPledge: 1, trailingCode: true)
    public static let DE = Country(countryCode: "DE", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let DK = Country(countryCode: "DK", currencyCode: "DKK", currencySymbol: "kr", maxPledge: 50_000, minPledge: 5, trailingCode: true)
    public static let ES = Country(countryCode: "ES", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let FR = Country(countryCode: "FR", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let GB = Country(countryCode: "GB", currencyCode: "GBP", currencySymbol: "£",  maxPledge: 5_000, minPledge: 1, trailingCode: false)
    public static let HK = Country(countryCode: "HK", currencyCode: "HKD", currencySymbol: "$",  maxPledge: 70_000, minPledge: 10, trailingCode: true)
    public static let IE = Country(countryCode: "IE", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let IT = Country(countryCode: "IT", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let LU = Country(countryCode: "LU", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let MX = Country(countryCode: "MX", currencyCode: "MXN", currencySymbol: "$",  maxPledge: 200_000, minPledge: 10, trailingCode: true)
    public static let NL = Country(countryCode: "NL", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let NO = Country(countryCode: "NO", currencyCode: "NOK", currencySymbol: "kr", maxPledge: 50_000, minPledge: 5, trailingCode: true)
    public static let NZ = Country(countryCode: "NZ", currencyCode: "NZD", currencySymbol: "$",  maxPledge: 8_000, minPledge: 1, trailingCode: true)
    public static let SE = Country(countryCode: "SE", currencyCode: "SEK", currencySymbol: "kr", maxPledge: 50_000, minPledge: 5, trailingCode: true)
    public static let SG = Country(countryCode: "SG", currencyCode: "SGD", currencySymbol: "$",  maxPledge: 10_000, minPledge: 2, trailingCode: true)
    public static let US = Country(countryCode: "US", currencyCode: "USD", currencySymbol: "$",  maxPledge: 10_000, minPledge: 1, trailingCode: true)
    // swiftlint:enable line_length
    // swiftlint:enable comma

    public static let all: [Country] = [
      .AU, .AT, .BE, .CA, .CH, .DE, .DK, .ES, .FR, .GB, .HK, .IE, .IT, .LU, .MX, .NL, .NO, .NZ, .SE, .SG, .US
    ]
  }
}

extension Project.Country {
  public init?(currencyCode: String) {
    guard
      let country = Project.Country.all.first(where: { $0.currencyCode == currencyCode })
      else { return nil }
    self = country
  }
}

extension Project.Country: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<Project.Country> {
    let create = curry(Project.Country.init)

    let tmp = create
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
  public func encode() -> [String:Any] {
    var result: [String:Any] = [:]
    result["country"] = self.countryCode
    result["currency"] = self.currencyCode
    result["currency_symbol"] = self.currencySymbol
    result["currency_trailing_code"] = self.trailingCode
    return result
  }
}

extension Project.Country: Equatable {}
public func == (lhs: Project.Country, rhs: Project.Country) -> Bool {
  return lhs.countryCode == rhs.countryCode
    && lhs.currencySymbol == rhs.currencySymbol
    && lhs.currencyCode == rhs.currencyCode
    && lhs.trailingCode == rhs.trailingCode
}

extension Project.Country: CustomStringConvertible {
  public var description: String {
    return "(\(self.countryCode), \(self.currencyCode), \(self.currencySymbol))"
  }
}
