import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `GraphComment`
   */
  static func comment(from graphComment: GraphComment) -> Comment {
    return Comment(
      author: Author(
        id: graphComment.author.id,
        isCreator: graphComment.author.isCreator,
        name: graphComment.author.name
      ),
      body: graphComment.body,
      id: graphComment.id,
      uid: decompose(id: graphComment.id) ?? -1,
      replyCount: graphComment.replyCount
    )
  }

  /**
   Returns a minimal `Comment` from a `CommentFragment`
   */
  static func comment(from commentFragment: CommentFragment) -> Comment? {
    guard
      let authorId = commentFragment.author?.id,
      let authorName = commentFragment.author?.name
    else { return nil }

    return Comment(
      author: Author(
        id: authorId,
        isCreator: commentFragment.author?.isCreator ?? false,
        name: authorName
      ),
      body: commentFragment.body,
      id: commentFragment.id,
      uid: decompose(id: commentFragment.id) ?? -1,
      replyCount: commentFragment.replies?.totalCount ?? 0
    )
  }
}
