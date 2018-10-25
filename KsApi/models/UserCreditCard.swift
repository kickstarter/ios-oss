public struct GraphUserCreditCard: Swift.Decodable {

  public private(set) var storedCards: CreditCardConnection

  public struct CreditCard: Swift.Decodable, Equatable {
    public private(set) var expirationDate: String
    public private(set) var id: String
    public private(set) var lastFour: String
    public private(set) var type: String
  }

  public struct CreditCardConnection: Swift.Decodable {
    public let nodes: [CreditCard]
  }
}
