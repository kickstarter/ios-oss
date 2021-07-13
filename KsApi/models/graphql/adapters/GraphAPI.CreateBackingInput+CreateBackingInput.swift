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
      applePay: GraphAPI.ApplePayInput.from(input.applePay)
    )
  }
}

extension GraphAPI.ApplePayInput {
  static func from(_ input: ApplePayParams?) -> GraphAPI.ApplePayInput? {
    guard let input = input else { return nil }
    return GraphAPI.ApplePayInput(
      token: input.token,
      paymentInstrumentName: input.paymentInstrumentName,
      paymentNetwork: input.paymentNetwork,
      transactionIdentifier: input.transactionIdentifier
    )
  }
}
