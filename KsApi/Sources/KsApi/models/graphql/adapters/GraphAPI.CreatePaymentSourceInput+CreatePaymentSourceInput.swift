import Foundation
import GraphAPI

extension GraphAPI.CreatePaymentSourceInput {
  static func from(_ input: CreatePaymentSourceInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      paymentType: GraphQLEnum.caseOrNil(.creditCard),
      reusable: GraphQLNullable.someOrNil(input.reusable),
      stripeCardId: GraphQLNullable.someOrNil(input.stripeCardId),
      stripeToken: GraphQLNullable.someOrNil(input.stripeToken)
    )
  }

  static func from(_ input: CreatePaymentSourceSetupIntentInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      intentClientSecret: GraphQLNullable.someOrNil(input.intentClientSecret),
      reusable: GraphQLNullable.someOrNil(input.reuseable)
    )
  }
}
