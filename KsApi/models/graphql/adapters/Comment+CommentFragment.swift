import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `CommentBaseFragment`
   */
  static func comment(from commentBaseFragment: GraphAPI.CommentBaseFragment, replyCount: Int?) -> Comment? {
    guard
      let author = commentBaseFragment.author,
      let decomposedAuthorId = decompose(id: author.id)
    else { return nil }

    let authorBadges = commentBaseFragment.authorBadges?
      .compactMap { $0 }
      .compactMap { Comment.AuthorBadge(rawValue: $0.rawValue) } ?? []

    let commentAuthor = Comment.Author(
      id: "\(decomposedAuthorId)",
      imageUrl: author.imageUrl,
      isBlocked: author.isBlocked ?? false,
      isCreator: author.isCreator ?? false,
      name: author.name
    )

    return Comment(
      author: commentAuthor,
      authorBadges: authorBadges,
      body: commentBaseFragment.body,
      createdAt: commentBaseFragment.createdAt.flatMap(TimeInterval.init),
      id: commentBaseFragment.id,
      isDeleted: commentBaseFragment.deleted,
      parentId: commentBaseFragment.parentId,
      replyCount: replyCount,
      hasFlaggings: commentBaseFragment.hasFlaggings,
      removedPerGuidelines: commentBaseFragment.removedPerGuidelines,
      sustained: commentBaseFragment.sustained,
      status: .success
    )
  }
}
