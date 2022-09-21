import Foundation

extension CreatePaymentSourceEnvelope {
  internal static let paymentSourceSuccessTemplate = CreatePaymentSourceEnvelope(
    createPaymentSource: .init(isSuccessful: true, paymentSource: UserCreditCards.amex)
  )
  internal static let paymentSourceFailureTemplate = CreatePaymentSourceEnvelope(
    createPaymentSource: .init(isSuccessful: false, paymentSource: UserCreditCards.amex)
  )
}
