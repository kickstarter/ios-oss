public struct GraphUserCreditCard: Swift.Decodable {

  public var storedCards: CreditCardConnection

  public struct CreditCard: Swift.Decodable, Equatable {
    public var expirationDate: String
    public var id: String
    public var lastFour: String
    public var type: CreditCardType?

    public var formattedExpirationDate: String {
      return String(expirationDate.dropLast(3))
    }

    public var imageName: String {
      switch self.type {
      case nil, .some(.generic):
        return "icon--generic"
      case .some(let type):
        return "icon--\(type.rawValue.lowercased())"
      }
    }
  }

  public enum CreditCardType: String, Decodable, CaseIterable {
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
