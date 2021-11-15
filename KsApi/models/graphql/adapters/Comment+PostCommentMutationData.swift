import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `GraphAPI.PostCommentMutation.Data.CreateComment.Comment`
   */

  static func from(_ data: GraphAPI.PostCommentMutation.Data.CreateComment.Comment) -> Comment? {
    guard let author = data.author,
      let decomposedAuthorId = decompose(id: author.id) else {
      return nil
    }

    let commentAuthor = Comment.Author(
      id: "\(decomposedAuthorId)",
      imageUrl: author.imageUrl,
      isCreator: author.isCreator ?? false,
      name: author.name
    )

    let commentBadges: [GraphAPI.CommentBadge?] = data.authorBadges ?? []
    let commentAuthorBadges: [Comment.AuthorBadge] = commentBadges.compactMap { badge in
      guard let existingBadge = badge else {
        return nil
      }

      return Comment.AuthorBadge(rawValue: existingBadge.rawValue)
    }

    let comment = Comment(
      author: commentAuthor,
      authorBadges: commentAuthorBadges,
      body: data.body,
      createdAt: data.createdAt.flatMap(TimeInterval.init) ?? 0,
      id: data.id,
      isDeleted: data.deleted,
      parentId: data.parentId,
      replyCount: data.replies?.totalCount ?? 0,
      status: .success
    )

    return comment
  }
}
