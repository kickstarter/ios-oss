import GraphAPI

extension GraphAPI.TriggerThirdPartyEventInput {
  static func from(_ input: TriggerThirdPartyEventInput) -> GraphAPI.TriggerThirdPartyEventInput {
    return GraphAPI.TriggerThirdPartyEventInput(
      deviceId: input.deviceId,
      eventName: input.eventName,
      projectId: input.projectId,
      pledgeAmount: GraphQLNullable.someOrNil(input.pledgeAmount),
      shipping: GraphQLNullable.someOrNil(input.shipping),
      transactionId: GraphQLNullable.someOrNil(input.transactionId),
      userId: GraphQLNullable.someOrNil(input.userId),
      appData: GraphQLNullable.someOrNil(input.appData),
      clientMutationId: GraphQLNullable.someOrNil(input.clientMutationId)
    )
  }
}
