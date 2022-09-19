import Foundation

extension GraphAPI.CreatePaymentSourceInput {
  static func from(_ input: CreatePaymentSourceInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      paymentType: .creditCard,
      stripeToken: input.stripeToken,
      stripeCardId: input.stripeCardId,
      reusable: input.reusable
    )
  }

  static func from(_ input: CreatePaymentSourceSetupIntentInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      reusable: input.reuseable,
      intentClientSecret: input.intentClientSecret
    )
  }
}
