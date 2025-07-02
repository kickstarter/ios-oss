import Foundation

extension GraphAPI.UpdateBackingInput {
  static func from(_ input: UpdateBackingInput) -> GraphAPI.UpdateBackingInput {
    return GraphAPI.UpdateBackingInput(
      id: input.id,
      amount: GraphQLInput.someOrNil(input.amount),
      rewardIds: GraphQLInput.someOrNil(input.rewardIds),
      locationId: GraphQLInput.someOrNil(input.locationId),
      paymentSourceId: GraphQLInput.someOrNil(input.paymentSourceId),
      intentClientSecret: GraphQLInput.someOrNil(input.setupIntentClientSecret),
      applePay: GraphQLInput.someOrNil(GraphAPI.ApplePayInput.from(input.applePay))
    )
  }
}
