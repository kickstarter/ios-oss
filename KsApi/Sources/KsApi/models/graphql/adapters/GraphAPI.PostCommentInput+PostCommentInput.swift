import GraphAPI

extension GraphAPI.PostCommentInput {
  static func from(_ input: PostCommentInput) -> GraphAPI.PostCommentInput {
    return GraphAPI.PostCommentInput(
      body: input.body,
      commentableId: input.commentableId,
      parentId: GraphQLNullable.someOrNil(input.parentId)
    )
  }
}
