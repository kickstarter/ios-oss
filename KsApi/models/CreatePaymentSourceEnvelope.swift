import Foundation

public struct CreatePaymentSourceEnvelope: Decodable {
  public private(set) var createPaymentSource: CreatePaymentSource

  public struct CreatePaymentSource: Decodable {
    public private(set) var errorMessage: String?
    public private(set) var isSuccessful: Bool
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
