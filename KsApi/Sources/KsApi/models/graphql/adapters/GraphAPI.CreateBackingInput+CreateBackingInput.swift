import Foundation
import GraphAPI

extension GraphAPI.CreateBackingInput {
  static func from(_ input: CreateBackingInput) -> GraphAPI.CreateBackingInput {
    return GraphAPI.CreateBackingInput(
      projectId: input.projectId,
      amount: GraphQLNullable.someOrNil(input.amount),
      locationId: GraphQLNullable.someOrNil(input.locationId),
      rewardIds: GraphQLNullable.someOrNil(input.rewardIds),
      refParam: GraphQLNullable.someOrNil(input.refParam),
      paymentSourceId: GraphQLNullable.someOrNil(input.paymentSourceId),
      setupIntentClientSecret: GraphQLNullable.someOrNil(input.setupIntentClientSecret),
      applePay: GraphQLNullable.someOrNil(GraphAPI.ApplePayInput.from(input.applePay)),
      incremental: GraphQLNullable.someOrNil(input.incremental)
    )
  }
}
