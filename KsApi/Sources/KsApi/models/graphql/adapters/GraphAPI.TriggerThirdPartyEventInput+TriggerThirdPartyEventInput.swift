import GraphAPI

extension GraphAPI.TriggerThirdPartyEventInput {
  static func from(_ input: TriggerThirdPartyEventInput) -> GraphAPI.TriggerThirdPartyEventInput {
    return GraphAPI.TriggerThirdPartyEventInput(
      clientMutationId: GraphQLNullable.someOrNil(input.clientMutationId),
      appData: GraphQLNullable.someOrNil(input.appData),
      deviceId: input.deviceId,
      eventName: input.eventName,
      pledgeAmount: GraphQLNullable.someOrNil(input.pledgeAmount),
      projectId: input.projectId,
      shipping: GraphQLNullable.someOrNil(input.shipping),
      transactionId: GraphQLNullable.someOrNil(input.transactionId),
      userId: GraphQLNullable.someOrNil(input.userId)
    )
  }
}
