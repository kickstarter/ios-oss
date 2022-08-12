import Foundation

extension GraphAPI.CreateBackingInput {
  static func from(_ input: CreateBackingInput) -> GraphAPI.CreateBackingInput {
    return GraphAPI.CreateBackingInput(
      projectId: input.projectId,
      amount: input.amount,
      locationId: input.locationId,
      rewardIds: input.rewardIds,
      refParam: input.refParam,
      paymentSourceId: input.paymentSourceId,
      setupIntentClientSecret: nil,
      applePay: GraphAPI.ApplePayInput.from(input.applePay)
    )
  }
}
