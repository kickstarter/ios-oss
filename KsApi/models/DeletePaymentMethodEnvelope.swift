import Foundation

public struct DeletePaymentMethodEnvelope {
  public let storedCards: [GraphUserCreditCard.CreditCard]
}

extension DeletePaymentMethodEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case nodes
    case paymentSourceDelete
    case user
    case storedCards
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.storedCards = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .paymentSourceDelete)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .user)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .storedCards)
      .decode([GraphUserCreditCard.CreditCard].self, forKey: .nodes)
  }
}
