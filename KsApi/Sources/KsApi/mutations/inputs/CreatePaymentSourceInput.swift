import Foundation

public struct CreatePaymentSourceInput: GraphMutationInput {
  let paymentType: PaymentType
  let reusable: Bool
  let stripeToken: String
  let stripeCardId: String

  public init(paymentType: PaymentType, reusable: Bool, stripeToken: String, stripeCardId: String) {
    self.paymentType = paymentType
    self.reusable = reusable
    self.stripeToken = stripeToken
    self.stripeCardId = stripeCardId
  }

  public func toInputDictionary() -> [String: Any] {
    return [
      "paymentType": self.paymentType.rawValue,
      "reusable": self.reusable,
      "stripeToken": self.stripeToken,
      "stripeCardId": self.stripeCardId
    ]
  }
}
