import Foundation

extension GraphAPI.CreatePaymentSourceInput {
  static func from(_ input: CreatePaymentSourceInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      paymentType: .caseOrNil(.creditCard),
      stripeToken: .someOrNil(input.stripeToken),
      stripeCardId: .someOrNil(input.stripeCardId),
      reusable: .someOrNil(input.reusable)
    )
  }

  static func from(_ input: CreatePaymentSourceSetupIntentInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      reusable: .someOrNil(input.reuseable),
      intentClientSecret: .someOrNil(input.intentClientSecret)
    )
  }
}
