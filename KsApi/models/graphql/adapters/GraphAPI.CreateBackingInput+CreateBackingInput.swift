import Foundation

extension GraphAPI.CreateBackingInput {
  static func from(_ input: CreateBackingInput) -> GraphAPI.CreateBackingInput {
    return GraphAPI.CreateBackingInput(
      projectId: input.projectId,
      amount: GraphQLInput.someOrNil(input.amount),
      locationId: GraphQLInput.someOrNil(input.locationId),
      rewardIds: GraphQLInput.someOrNil(input.rewardIds),
      refParam: GraphQLInput.someOrNil(input.refParam),
      paymentSourceId: GraphQLInput.someOrNil(input.paymentSourceId),
      setupIntentClientSecret: GraphQLInput.someOrNil(input.setupIntentClientSecret),
      applePay: GraphQLInput.someOrNil(GraphAPI.ApplePayInput.from(input.applePay)),
      incremental: GraphQLInput.someOrNil(input.incremental)
    )
  }
}
