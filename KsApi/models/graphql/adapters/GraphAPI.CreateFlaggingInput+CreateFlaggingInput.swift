extension GraphAPI.CreateFlaggingInput {
  static func from(_ input: CreateFlaggingInput) -> GraphAPI.CreateFlaggingInput {
    return GraphAPI.CreateFlaggingInput(
      contentId: input.contentId,
      kind: GraphQLInput.someCase(input.kind),
      details: GraphQLInput.someOrNil(input.details),
      clientMutationId: GraphQLInput.someOrNil(input.clientMutationId)
    )
  }
}
