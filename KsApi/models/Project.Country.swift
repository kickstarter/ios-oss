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
    public static let au = Country(countryCode: "AU", currencyCode: "AUD", currencySymbol: "$",  maxPledge: 7_000, minPledge: 1, trailingCode: true)
    public static let at = Country(countryCode: "AT", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 8_000, minPledge: 1, trailingCode: false)
    public static let be = Country(countryCode: "BE", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let ca = Country(countryCode: "CA", currencyCode: "CAD", currencySymbol: "$",  maxPledge: 8_000, minPledge: 1, trailingCode: true)
    public static let ch = Country(countryCode: "CH", currencyCode: "CHF", currencySymbol: "Fr", maxPledge: 7_000, minPledge: 1, trailingCode: true)
    public static let de = Country(countryCode: "DE", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let dk = Country(countryCode: "DK", currencyCode: "DKK", currencySymbol: "kr", maxPledge: 50_000, minPledge: 5, trailingCode: true)
    public static let es = Country(countryCode: "ES", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let fr = Country(countryCode: "FR", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let gb = Country(countryCode: "GB", currencyCode: "GBP", currencySymbol: "£",  maxPledge: 5_000, minPledge: 1, trailingCode: false)
    public static let hk = Country(countryCode: "HK", currencyCode: "HKD", currencySymbol: "$",  maxPledge: 70_000, minPledge: 10, trailingCode: true)
    public static let ie = Country(countryCode: "IE", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let it = Country(countryCode: "IT", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let jp = Country(countryCode: "JP", currencyCode: "JPY", currencySymbol: "¥",  maxPledge: 1_200_000, minPledge: 100, trailingCode: false)
    public static let lu = Country(countryCode: "LU", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let mx = Country(countryCode: "MX", currencyCode: "MXN", currencySymbol: "$",  maxPledge: 200_000, minPledge: 10, trailingCode: true)
    public static let nl = Country(countryCode: "NL", currencyCode: "EUR", currencySymbol: "€",  maxPledge: 7_000, minPledge: 1, trailingCode: false)
    public static let no = Country(countryCode: "NO", currencyCode: "NOK", currencySymbol: "kr", maxPledge: 50_000, minPledge: 5, trailingCode: true)
    public static let nz = Country(countryCode: "NZ", currencyCode: "NZD", currencySymbol: "$",  maxPledge: 8_000, minPledge: 1, trailingCode: true)
    public static let se = Country(countryCode: "SE", currencyCode: "SEK", currencySymbol: "kr", maxPledge: 50_000, minPledge: 5, trailingCode: true)
    public static let sg = Country(countryCode: "SG", currencyCode: "SGD", currencySymbol: "$",  maxPledge: 10_000, minPledge: 2, trailingCode: true)
    public static let us = Country(countryCode: "US", currencyCode: "USD", currencySymbol: "$",  maxPledge: 10_000, minPledge: 1, trailingCode: true)
    // swiftlint:enable line_length
    // swiftlint:enable comma

    public static let all: [Country] = [
      .au, .at, .be, .ca, .ch, .de, .dk, .es, .fr, .gb, .hk, .ie, .it, .jp, .lu, .mx, .nl, .no, .nz, .se, .sg,
      .us
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
