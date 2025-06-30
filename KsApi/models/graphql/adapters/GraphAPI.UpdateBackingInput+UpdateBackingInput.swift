import Foundation

extension GraphAPI.UpdateBackingInput {
  static func from(_ input: UpdateBackingInput) -> GraphAPI.UpdateBackingInput {
    return GraphAPI.UpdateBackingInput(
      id: input.id,
      amount: .someOrNil(input.amount),
      rewardIds: .someOrNil(input.rewardIds),
      locationId: .someOrNil(input.locationId),
      paymentSourceId: .someOrNil(input.paymentSourceId),
      intentClientSecret: .someOrNil(input.setupIntentClientSecret),
      applePay: .someOrNil(GraphAPI.ApplePayInput.from(input.applePay))
    )
  }
}
