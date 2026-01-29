import Foundation
import GraphAPI

extension GraphAPI.UpdateBackingInput {
  static func from(_ input: UpdateBackingInput) -> GraphAPI.UpdateBackingInput {
    return GraphAPI.UpdateBackingInput(
      id: input.id,
      amount: GraphQLNullable.someOrNil(input.amount),
      rewardIds: GraphQLNullable.someOrNil(input.rewardIds),
      locationId: GraphQLNullable.someOrNil(input.locationId),
      paymentSourceId: GraphQLNullable.someOrNil(input.paymentSourceId),
      intentClientSecret: GraphQLNullable.someOrNil(input.setupIntentClientSecret),
      applePay: GraphQLNullable.someOrNil(
        GraphAPI.ApplePayInput.from(input.applePay)
      ),
      incremental: GraphQLNullable.someOrNil(input.incremental)
    )
  }
}
