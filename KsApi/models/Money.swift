import Foundation

public struct Money: Swift.Decodable, Equatable {
  public var amount: String?
  public var currency: CurrencyCode?
  public var symbol: String?

  public enum CurrencyCode: String, CaseIterable, Swift.Decodable, Equatable {
    case aud = "AUD"
    case cad = "CAD"
    case chf = "CHF"
    case dkk = "DKK"
    case eur = "EUR"
    case gbp = "GBP"
    case hkd = "HKD"
    case jpy = "JPY"
    case mxn = "MXN"
    case nok = "NOK"
    case nzd = "NZD"
    case pln = "PLN"
    case sek = "SEK"
    case sgd = "SGD"
    case usd = "USD"
  }
}
