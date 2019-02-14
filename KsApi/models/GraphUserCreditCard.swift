public struct GraphUserCreditCard: Swift.Decodable {

  public private(set) var storedCards: CreditCardConnection

  public struct CreditCard: Swift.Decodable, Equatable {
    public private(set) var expirationDate: String
    public private(set) var id: String
    public private(set) var lastFour: String
    public private(set) var type: CreditCardType?

    public var formattedExpirationDate: String {
      return String(expirationDate.dropLast(3))
    }

    public var imageName: String {
      switch self.type {
      case .generic:
        return "icon--generic"
      default:
        return "icon--\(self.type.rawValue.lowercased())"
      }
    }
  }

  public enum CreditCardType: String, Decodable, CaseIterable {
    case amex = "AMEX"
    case discover = "DISCOVER"
    case jcb = "JCB"
    case mastercard = "MASTERCARD"
    case visa = "VISA"
    case diners = "DINERS"
    case generic = "----"

    public var description: String? {
      switch self {
      case .amex, .discover, .jcb, .mastercard, .visa, .diners:
        return self.rawValue.capitalized
      default:
        return nil
      }
    }
  }

  public struct CreditCardConnection: Swift.Decodable {
    public let nodes: [CreditCard]
  }
}
