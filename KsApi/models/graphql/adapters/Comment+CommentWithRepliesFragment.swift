import Foundation

extension Comment {
  /**
   Returns a minimal `Comment` from a `CommentWithRepliesFragment`
   */
  static func comment(from commentWithRepliesFragment: GraphAPI.CommentWithRepliesFragment) -> Comment? {
    guard
      let authorId = commentWithRepliesFragment.author?.fragments.userFragment.id,
      let decomposedAuthorId = decompose(id: authorId),
      let authorImageUrl = commentWithRepliesFragment.author?.fragments.userFragment.imageUrl,
      let authorName = commentWithRepliesFragment.author?.fragments.userFragment.name
    else { return nil }

    let authorBadges = commentWithRepliesFragment.authorBadges?
      .compactMap { $0 }
      .compactMap { Comment.AuthorBadge(rawValue: $0.rawValue) } ?? []

    return Comment(
      author: Author(
        id: "\(decomposedAuthorId)",
        imageUrl: authorImageUrl,
        isCreator: commentWithRepliesFragment.author?.fragments.userFragment.isCreator ?? false,
        name: authorName
      ),
      authorBadges: authorBadges,
      body: commentWithRepliesFragment.body,
      createdAt: commentWithRepliesFragment.createdAt.flatMap(TimeInterval.init) ?? 0,
      id: commentWithRepliesFragment.id,
      isDeleted: commentWithRepliesFragment.deleted,
      replyCount: commentWithRepliesFragment.replies?.totalCount ?? 0,
      status: .success
    )
  }
}
