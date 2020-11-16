import Foundation

public struct CreatePaymentSourceEnvelope: Decodable {
  public var createPaymentSource: CreatePaymentSource

  public struct CreatePaymentSource: Decodable {
    public var errorMessage: String?
    public var isSuccessful: Bool
    public var paymentSource: GraphUserCreditCard.CreditCard
  }
}

extension CreatePaymentSourceEnvelope {
  private enum CodingKeys: String, CodingKey {
    case createPaymentSource
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.createPaymentSource = try values.decode(CreatePaymentSource.self, forKey: .createPaymentSource)
  }
}
