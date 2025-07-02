import Foundation

extension GraphAPI.CreatePaymentSourceInput {
  static func from(_ input: CreatePaymentSourceInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      paymentType: GraphQLInput.caseOrNil(.creditCard),
      stripeToken: GraphQLInput.someOrNil(input.stripeToken),
      stripeCardId: GraphQLInput.someOrNil(input.stripeCardId),
      reusable: GraphQLInput.someOrNil(input.reusable)
    )
  }

  static func from(_ input: CreatePaymentSourceSetupIntentInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      reusable: GraphQLInput.someOrNil(input.reuseable),
      intentClientSecret: GraphQLInput.someOrNil(input.intentClientSecret)
    )
  }
}
