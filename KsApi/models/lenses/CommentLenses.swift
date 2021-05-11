import Prelude

extension DeprecatedComment {
  public enum lens {
    public static let author = Lens<DeprecatedComment, DeprecatedAuthor>(
      view: { $0.author },
      set: {
        DeprecatedComment(
          author: $0,
          body: $1.body,
          createdAt: $1.createdAt,
          deletedAt: $1.deletedAt,
          id: $1.id
        )
      }
    )

    public static let body = Lens<DeprecatedComment, String>(
      view: { $0.body },
      set: { DeprecatedComment(
        author: $1.author, body: $0, createdAt: $1.createdAt, deletedAt: $1.deletedAt,
        id: $1.id
      ) }
    )

    public static let createdAt = Lens<DeprecatedComment, TimeInterval>(
      view: { $0.createdAt },
      set: {
        DeprecatedComment(author: $1.author, body: $1.body, createdAt: $0, deletedAt: $1.deletedAt, id: $1.id)
      }
    )

    public static let deletedAt = Lens<DeprecatedComment, TimeInterval?>(
      view: { $0.deletedAt },
      set: {
        DeprecatedComment(author: $1.author, body: $1.body, createdAt: $1.createdAt, deletedAt: $0, id: $1.id)
      }
    )

    public static let id = Lens<DeprecatedComment, Int>(
      view: { $0.id },
      set: { DeprecatedComment(
        author: $1.author, body: $1.body, createdAt: $1.createdAt, deletedAt: $1.deletedAt,
        id: $0
      ) }
    )
  }
}
