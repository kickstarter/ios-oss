extension GraphAPI.TriggerThirdPartyEventInput {
  static func from(_ input: TriggerThirdPartyEventInput) -> GraphAPI.TriggerThirdPartyEventInput {
    return GraphAPI.TriggerThirdPartyEventInput(
      deviceId: input.deviceId,
      eventName: input.eventName,
      projectId: input.projectId,
      pledgeAmount: .someOrNil(input.pledgeAmount),
      shipping: .someOrNil(input.shipping),
      transactionId: .someOrNil(input.transactionId),
      userId: .someOrNil(input.userId),
      appData: .someOrNil(input.appData),
      clientMutationId: .someOrNil(input.clientMutationId)
    )
  }
}
