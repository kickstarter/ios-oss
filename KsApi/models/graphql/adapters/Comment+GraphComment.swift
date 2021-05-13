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
}
