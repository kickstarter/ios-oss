import Foundation

extension CreatePaymentSourceEnvelope {
  internal static let paymentSourceSuccessTemplate = CreatePaymentSourceEnvelope(
    createPaymentSource: .init(isSuccessful: true, paymentSource: UserCreditCards.amex)
  )
  internal static let paymentSourceFailureTemplate = CreatePaymentSourceEnvelope(
    createPaymentSource: .init(isSuccessful: false, paymentSource: UserCreditCards.amex)
  )
  public static func paymentSourceSuccessTemplateWithId(_ id: String) -> CreatePaymentSourceEnvelope {
    let card = UserCreditCards.CreditCard(
      expirationDate: "2024-01-12",
      id: id,
      lastFour: "8882",
      type: .visa
    )

    return CreatePaymentSourceEnvelope(
      createPaymentSource: .init(isSuccessful: true, paymentSource: card)
    )
  }
}
