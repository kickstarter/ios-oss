import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `GraphComment`
   */

  /**
   FIXME: Some of the properties needed for `Comment` hasn't been mapped out on GraphComment. We are returning default values.
   These properties are `Author.imageUrl`, `authorBadges`, `createdAt`, `deletedAt`, `isDeleted`
   */
  static func comment(from graphComment: GraphComment) -> Comment {
    return Comment(
      author: Author(
        id: graphComment.author.id,
        imageUrl: "",
        isCreator: graphComment.author.isCreator,
        name: graphComment.author.name
      ),
      authorBadges: nil,
      body: graphComment.body,
      createdAt: TimeInterval.init(),
      deletedAt: TimeInterval.init(),
      id: graphComment.id,
      isDeleted: false,
      uid: decompose(id: graphComment.id) ?? -1,
      replyCount: graphComment.replyCount
    )
  }
}
