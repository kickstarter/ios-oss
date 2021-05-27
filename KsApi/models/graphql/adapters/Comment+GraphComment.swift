import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `GraphComment`
   */
  static func comment(from graphComment: GraphComment) -> Comment {
    var authorBadges = [Comment.Author.AuthorBadge]()
    
    graphComment.authorBadges.forEach { graphCommentBadge in
      if let commentBadge = Comment.Author.AuthorBadge(rawValue: graphCommentBadge.rawValue) {
        authorBadges.append(commentBadge)
      }
    }
    
    return Comment(
      author: Author(
        id: graphComment.author.id,
        imageUrl: graphComment.author.imageUrl,
        isCreator: graphComment.author.isCreator,
        name: graphComment.author.name
      ),
      authorBadges: authorBadges,
      body: graphComment.body,
      createdAt: graphComment.createdAt,
      id: graphComment.id,
      isDeleted: graphComment.deleted,
      uid: decompose(id: graphComment.id) ?? -1,
      replyCount: graphComment.replyCount
    )
  }
}
