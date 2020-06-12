import Argo
import Foundation

public enum CreditCardType: String, Swift.Decodable, CaseIterable {
  case amex = "AMEX"
  case diners = "DINERS"
  case discover = "DISCOVER"
  case jcb = "JCB"
  case mastercard = "MASTERCARD"
  case unionPay = "UNION_PAY"
  case visa = "VISA"
  case generic = "----"

  public var description: String? {
    switch self {
    case .amex, .discover, .jcb, .mastercard, .visa, .diners:
      return self.rawValue.capitalized
    case .unionPay:
      return self.rawValue
        .capitalized
        .replacingOccurrences(of: "_", with: " ")
    default:
      return nil
    }
  }

  public init(from decoder: Decoder) throws {
    let decodedValue = try decoder.singleValueContainer().decode(String.self)

    self = CreditCardType(rawValue: decodedValue) ?? .generic
  }
}

extension CreditCardType: Argo.Decodable {}
