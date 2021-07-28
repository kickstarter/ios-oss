import Foundation

extension CreatePaymentSourceEnvelope {
  internal static let paymentSourceSuccessTemplate = CreatePaymentSourceEnvelope(
    createPaymentSource: .init(isSuccessful: true, paymentSource: GraphUserCreditCard.amex)
  )
}
