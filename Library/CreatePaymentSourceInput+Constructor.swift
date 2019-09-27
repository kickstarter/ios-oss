import Foundation
import KsApi

extension CreatePaymentSourceInput {
  internal static func input(
    fromToken token: String,
    stripeCardId: String,
    reusable: Bool
  ) -> CreatePaymentSourceInput {
    return CreatePaymentSourceInput(
      paymentType: PaymentType.creditCard,
      reusable: reusable,
      stripeToken: token,
      stripeCardId: stripeCardId
    )
  }
}
