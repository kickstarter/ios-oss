extension GraphAPI.TriggerThirdPartyEventInput {
  static func from(_ input: TriggerThirdPartyEventInput) -> GraphAPI.TriggerThirdPartyEventInput {
    return GraphAPI.TriggerThirdPartyEventInput(
      deviceId: input.deviceId,
      eventName: input.eventName,
      projectId: input.projectId,
      pledgeAmount: input.pledgeAmount,
      shipping: input.shipping,
      transactionId: input.transactionId,
      userId: input.userId,
      appData: input.appData,
      clientMutationId: input.clientMutationId
    )
  }
}
