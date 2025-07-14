import GraphAPI

extension GraphAPI.CreateFlaggingInput {
  static func from(_ input: CreateFlaggingInput) -> GraphAPI.CreateFlaggingInput {
    return GraphAPI.CreateFlaggingInput(
      contentId: input.contentId,
      kind: GraphQLEnum.case(input.kind),
      details: GraphQLNullable.someOrNil(input.details),
      clientMutationId: GraphQLNullable.someOrNil(input.clientMutationId)
    )
  }
}
