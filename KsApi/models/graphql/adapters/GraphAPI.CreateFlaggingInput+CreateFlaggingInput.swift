extension GraphAPI.CreateFlaggingInput {
  static func from(_ input: CreateFlaggingInput) -> GraphAPI.CreateFlaggingInput {
    return GraphAPI.CreateFlaggingInput(
      contentId: input.contentId,
      kind: .case(input.kind),
      details: .someOrNil(input.details),
      clientMutationId: .someOrNil(input.clientMutationId)
    )
  }
}
