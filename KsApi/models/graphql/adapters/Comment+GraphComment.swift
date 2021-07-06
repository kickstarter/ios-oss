import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `GraphComment`
   */
  static func comment(from graphComment: GraphComment) -> Comment {
    return Comment(
      author: Author(
        id: graphComment.author.id,
        imageUrl: graphComment.author.imageUrl,
        isCreator: graphComment.author.isCreator,
        name: graphComment.author.name
      ),
      authorBadges: graphComment.authorBadges.compactMap { Comment.AuthorBadge(rawValue: $0.rawValue) },
      body: graphComment.body,
      createdAt: graphComment.createdAt,
      id: graphComment.id,
      isDeleted: graphComment.deleted,
      parentId: graphComment.parentId,
      replyCount: graphComment.replyCount,
      status: .success
    )
  }
}
