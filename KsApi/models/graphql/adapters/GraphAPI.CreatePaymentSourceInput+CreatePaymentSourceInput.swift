import Foundation
import GraphAPI

extension GraphAPI.CreatePaymentSourceInput {
  static func from(_ input: CreatePaymentSourceInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      paymentType: GraphQLEnum.caseOrNil(.creditCard),
      stripeToken: GraphQLNullable.someOrNil(input.stripeToken),
      stripeCardId: GraphQLNullable.someOrNil(input.stripeCardId),
      reusable: GraphQLNullable.someOrNil(input.reusable)
    )
  }

  static func from(_ input: CreatePaymentSourceSetupIntentInput) -> GraphAPI.CreatePaymentSourceInput {
    return GraphAPI.CreatePaymentSourceInput(
      reusable: GraphQLNullable.someOrNil(input.reuseable),
      intentClientSecret: GraphQLNullable.someOrNil(input.intentClientSecret)
    )
  }
}
