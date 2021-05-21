import Prelude

extension Comment {
  public enum lens {
    public static let author = Lens<Comment, Comment.Author>(
      view: { $0.author },
      set: {
        Comment(
          author: $0,
          authorBadges: $1.authorBadges,
          body: $1.body,
          createdAt: $1.createdAt,
          deletedAt: $1.deletedAt,
          id: $1.id,
          isDeleted: $1.isDeleted,
          uid: $1.uid,
          replyCount: $1.replyCount
        )
      }
    )

    public static let authorBadges = Lens<Comment, [AuthorBadge]?>(
      view: { $0.authorBadges },
      set: {
        Comment(
          author: $1.author,
          authorBadges: $0,
          body: $1.body,
          createdAt: $1.createdAt,
          deletedAt: $1.deletedAt,
          id: $1.id,
          isDeleted: $1.isDeleted,
          uid: $1.uid,
          replyCount: $1.replyCount
        )
      }
    )

    public static let body = Lens<Comment, String>(
      view: { $0.body },
      set: {
        Comment(
          author: $1.author,
          authorBadges: $1.authorBadges,
          body: $0,
          createdAt: $1.createdAt,
          deletedAt: $1.deletedAt,
          id: $1.id,
          isDeleted: $1.isDeleted,
          uid: $1.uid,
          replyCount: $1.replyCount
        )
      }
    )

    public static let createdAt = Lens<Comment, TimeInterval>(
      view: { $0.createdAt },
      set: {
        Comment(
          author: $1.author,
          authorBadges: $1.authorBadges,
          body: $1.body,
          createdAt: $0,
          deletedAt: $1.deletedAt,
          id: $1.id,
          isDeleted: $1.isDeleted,
          uid: $1.uid,
          replyCount: $1.replyCount
        )
      }
    )

    public static let id = Lens<Comment, String>(
      view: { $0.id },
      set: {
        Comment(
          author: $1.author,
          authorBadges: $1.authorBadges,
          body: $1.body,
          createdAt: $1.createdAt,
          deletedAt: $1.deletedAt,
          id: $0,
          isDeleted: $1.isDeleted,
          uid: $1.uid,
          replyCount: $1.replyCount
        )
      }
    )

    public static let isDeleted = Lens<Comment, Bool>(
      view: { $0.isDeleted },
      set: {
        Comment(
          author: $1.author,
          authorBadges: $1.authorBadges,
          body: $1.body,
          createdAt: $1.createdAt,
          deletedAt: $1.deletedAt,
          id: $1.id,
          isDeleted: $0,
          uid: $1.uid,
          replyCount: $1.replyCount
        )
      }
    )
  }
}
