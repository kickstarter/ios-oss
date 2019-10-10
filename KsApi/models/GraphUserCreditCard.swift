import Argo
import Curry
import Runes

public struct GraphUserCreditCard: Swift.Decodable {
  public var storedCards: CreditCardConnection

  public struct CreditCard: Swift.Decodable, Equatable {
    public var expirationDate: String
    public var id: String
    public var lastFour: String
    public let paymentType: PaymentType?
    public let state: String?
    public var type: CreditCardType?

    public var formattedExpirationDate: String {
      return String(self.expirationDate.dropLast(3))
    }

    public var imageName: String {
      switch self.type {
      case nil, .some(.generic):
        return "icon--generic"
      case let .some(type):
        return "icon--\(type.rawValue.lowercased())"
      }
    }
  }

  public enum PaymentType: String, Swift.Decodable, CaseIterable {
    case applePay = "APPLE_PAY"
    case card = "CREDIT_CARD"
  }

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

  public struct CreditCardConnection: Swift.Decodable {
    public let nodes: [CreditCard]
  }
}

extension GraphUserCreditCard.CreditCard: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<GraphUserCreditCard.CreditCard> {
    return curry(GraphUserCreditCard.CreditCard.init)
      <^> json <| "expiration_date"
      <*> (json <| "id" <|> (json <| "id" >>- intToString))
      <*> json <| "last_four"
      <*> json <|? "payment_type"
      <*> json <| "state"
      <*> json <|? "type"
  }
}

extension GraphUserCreditCard.CreditCardType: Argo.Decodable {}

extension GraphUserCreditCard.PaymentType: Argo.Decodable {}

private func intToString(_ input: Int) -> Decoded<String> {
  return .success(Data("User-\(input)".utf8).base64EncodedString())
}
