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
      replyCount: graphComment.replyCount,
      status: .success
    )
  }

  /**
   Returns a minimal `Comment` from a `CommentFragment`
   */
  static func comment(from commentFragment: CommentFragment) -> Comment? {
    guard
      let authorId = commentFragment.author?.id,
      let authorImageUrl = commentFragment.author?.imageUrl,
      let authorName = commentFragment.author?.name
    else { return nil }

    let authorBagdes = commentFragment.authorBadges?
      .compactMap { $0 }
      .compactMap { Comment.AuthorBadge(rawValue: $0.rawValue) } ?? []

    return Comment(
      author: Author(
        id: authorId,
        imageUrl: authorImageUrl,
        isCreator: commentFragment.author?.isCreator ?? false,
        name: authorName
      ),
      authorBadges: authorBagdes,
      body: commentFragment.body,
      createdAt: commentFragment.createdAt.flatMap(TimeInterval.init) ?? 0,
      id: commentFragment.id,
      isDeleted: commentFragment.deleted,
      replyCount: commentFragment.replies?.totalCount ?? 0,
      status: .success
    )
  }
}
