extension GraphAPI.TriggerThirdPartyEventInput {
  static func from(_ input: TriggerThirdPartyEventInput) -> GraphAPI.TriggerThirdPartyEventInput {
    return GraphAPI.TriggerThirdPartyEventInput(
      deviceId: input.deviceId,
      eventName: input.eventName,
      projectId: input.projectId,
      pledgeAmount: GraphQLInput.someOrNil(input.pledgeAmount),
      shipping: GraphQLInput.someOrNil(input.shipping),
      transactionId: GraphQLInput.someOrNil(input.transactionId),
      userId: GraphQLInput.someOrNil(input.userId),
      appData: GraphQLInput.someOrNil(input.appData),
      clientMutationId: GraphQLInput.someOrNil(input.clientMutationId)
    )
  }
}
