

// TODO: Remove public access
public struct GraphUserCreditCard: Decodable {
  public var storedCards: CreditCardConnection

  public struct CreditCard: Decodable, Equatable {
    public var expirationDate: String
    public var id: String
    public var lastFour: String
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

  public struct CreditCardConnection: Decodable, Equatable {
    public let nodes: [CreditCard]
  }
}

extension GraphUserCreditCard: Equatable {
  public static func == (lhs: GraphUserCreditCard, rhs: GraphUserCreditCard) -> Bool {
    lhs.storedCards == rhs.storedCards
  }
}
