import Foundation

public struct CreatePaymentSourceInput: GraphMutationInput {
  let paymentType: GraphUserCreditCard
  let stripeToken: String
  let stripeCardId: String

  public init(paymentType: GraphUserCreditCard, stripeToken: String, stripeCardId: String) {
    self.paymentType = paymentType
    self.stripeToken = stripeToken
    self.stripeCardId = stripeCardId
  }

  public func toInputDictionary() -> [String : Any] {
    return ["paymentType": paymentType,
            "stripeToken": stripeToken,
            "stripeCardId": stripeCardId
    ]
  }
}
