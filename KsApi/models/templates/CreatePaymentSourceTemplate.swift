import Foundation

extension CreatePaymentSourceEnvelope {
  internal static let paymentSourceSuccessTemplate = CreatePaymentSourceEnvelope(
    createPaymentSource: .init(errorMessage: nil, isSuccessful: true, paymentSource: GraphUserCreditCard.amex)
  )
}
