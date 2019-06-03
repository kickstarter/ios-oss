import Foundation

public struct CreatePaymentSourceInput: GraphMutationInput {
  let paymentType: PaymentType
  let stripeToken: String
  let stripeCardId: String

  public init(paymentType: PaymentType, stripeToken: String, stripeCardId: String) {
    self.paymentType = paymentType
    self.stripeToken = stripeToken
    self.stripeCardId = stripeCardId
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "paymentType": paymentType.rawValue,
      "stripeToken": stripeToken,
      "stripeCardId": stripeCardId
    ]
  }
}
