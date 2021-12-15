import Foundation
import Prelude

public struct Money: Decodable, Equatable {
  public var amount: Double
  public var currency: CurrencyCode?
  public var symbol: String?

  public enum CurrencyCode: String, CaseIterable, Decodable, Equatable {
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

extension Money {
  private enum CodingKeys: CodingKey {
    case amount
    case currency
    case symbol
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    guard let amount = (try values.decode(String?.self, forKey: .amount)).flatMap(Double.init) else {
      throw DecodingError.dataCorruptedError(
        forKey: .amount, in: values, debugDescription: "Not a valid double"
      )
    }

    self.amount = amount
    self.currency = try values.decodeIfPresent(CurrencyCode.self, forKey: .currency)
    self.symbol = try values.decodeIfPresent(String.self, forKey: .symbol)
  }
}
