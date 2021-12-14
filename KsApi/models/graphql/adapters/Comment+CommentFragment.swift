import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `CommentFragment`
   */
  static func comment(from commentFragment: GraphAPI.CommentFragment) -> Comment? {
    guard
      let authorId = commentFragment.author?.fragments.userFragment.id,
      let decomposedAuthorId = decompose(id: authorId),
      let authorImageUrl = commentFragment.author?.fragments.userFragment.imageUrl,
      let authorName = commentFragment.author?.fragments.userFragment.name
    else { return nil }

    let authorBadges = commentFragment.authorBadges?
      .compactMap { $0 }
      .compactMap { Comment.AuthorBadge(rawValue: $0.rawValue) } ?? []

    return Comment(
      author: Author(
        id: "\(decomposedAuthorId)",
        imageUrl: authorImageUrl,
        isCreator: commentFragment.author?.fragments.userFragment.isCreator ?? false,
        name: authorName
      ),
      authorBadges: authorBadges,
      body: commentFragment.body,
      createdAt: commentFragment.createdAt.flatMap(TimeInterval.init) ?? 0,
      id: commentFragment.id,
      isDeleted: commentFragment.deleted,
      parentId: commentFragment.parentId,
      replyCount: commentFragment.replies?.totalCount ?? 0,
      status: .success
    )
  }
}
