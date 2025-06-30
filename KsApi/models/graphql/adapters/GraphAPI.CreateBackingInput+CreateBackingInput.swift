import Foundation

extension GraphAPI.CreateBackingInput {
  static func from(_ input: CreateBackingInput) -> GraphAPI.CreateBackingInput {
    return GraphAPI.CreateBackingInput(
      projectId: input.projectId,
      amount: .someOrNil(input.amount),
      locationId: .someOrNil(input.locationId),
      rewardIds: .someOrNil(input.rewardIds),
      refParam: .someOrNil(input.refParam),
      paymentSourceId: .someOrNil(input.paymentSourceId),
      setupIntentClientSecret: .someOrNil(input.setupIntentClientSecret),
      applePay: .someOrNil(GraphAPI.ApplePayInput.from(input.applePay)),
      incremental: .someOrNil(input.incremental)
    )
  }
}
