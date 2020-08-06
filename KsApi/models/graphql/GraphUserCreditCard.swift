import Argo
import Curry
import Runes

public struct GraphUserCreditCard: Swift.Decodable {
  public var storedCards: CreditCardConnection

  public struct CreditCard: Swift.Decodable, Equatable {
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

  public struct CreditCardConnection: Swift.Decodable {
    public let nodes: [CreditCard]
  }
}

private func intToString(_ input: Int) -> Decoded<String> {
  return .success(Data("User-\(input)".utf8).base64EncodedString())
}
