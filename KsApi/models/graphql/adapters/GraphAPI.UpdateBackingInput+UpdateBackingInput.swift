import Foundation

extension GraphAPI.UpdateBackingInput {
  static func from(_ input: UpdateBackingInput) -> GraphAPI.UpdateBackingInput {
    return GraphAPI.UpdateBackingInput(
      id: input.id,
      amount: input.amount,
      rewardIds: input.rewardIds,
      locationId: input.locationId,
      paymentSourceId: input.paymentSourceId,
      intentClientSecret: input.setupIntentClientSecret,
      applePay: GraphAPI.ApplePayInput.from(input.applePay)
    )
  }
}
