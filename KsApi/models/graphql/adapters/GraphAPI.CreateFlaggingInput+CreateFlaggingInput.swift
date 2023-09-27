extension GraphAPI.CreateFlaggingInput {
  static func from(_ input: CreateFlaggingInput) -> GraphAPI.CreateFlaggingInput {
    return GraphAPI.CreateFlaggingInput(
      contentId: input.contentId,
      kind: input.kind,
      details: input.details,
      clientMutationId: input.clientMutationId
    )
  }
}
