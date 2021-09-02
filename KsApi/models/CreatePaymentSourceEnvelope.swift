import Foundation

public struct CreatePaymentSourceEnvelope: Decodable {
  public var createPaymentSource: CreatePaymentSource

  public struct CreatePaymentSource: Decodable {
    public var isSuccessful: Bool
    public var paymentSource: UserCreditCards.CreditCard
  }
}
