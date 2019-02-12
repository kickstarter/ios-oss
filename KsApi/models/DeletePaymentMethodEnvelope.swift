import Foundation

public struct DeletePaymentMethodEnvelope {
  public let totalCount: Int
}

extension DeletePaymentMethodEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case data
    case user
    case storedCards
    case totalCount
    case paymentSourceDelete
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.totalCount = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .paymentSourceDelete)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .user)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .storedCards)
      .decode(Int.self, forKey: .totalCount)
  }
}
