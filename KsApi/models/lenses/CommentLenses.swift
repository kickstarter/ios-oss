import Prelude

extension Comment {
  public enum lens {
    public static let author = Lens<Comment, User>(
      view: { $0.author },
      set: { Comment(author: $0, body: $1.body, createdAt: $1.createdAt, deletedAt: $1.deletedAt, id: $1.id) }
    )

    public static let body = Lens<Comment, String>(
      view: { $0.body },
      set: { Comment(author: $1.author, body: $0, createdAt: $1.createdAt, deletedAt: $1.deletedAt,
        id: $1.id) }
    )

    public static let createdAt = Lens<Comment, TimeInterval>(
      view: { $0.createdAt },
      set: { Comment(author: $1.author, body: $1.body, createdAt: $0, deletedAt: $1.deletedAt, id: $1.id) }
    )

    public static let deletedAt = Lens<Comment, TimeInterval?>(
      view: { $0.deletedAt },
      set: { Comment(author: $1.author, body: $1.body, createdAt: $1.createdAt, deletedAt: $0, id: $1.id) }
    )

    public static let id = Lens<Comment, Int>(
      view: { $0.id },
      set: { Comment(author: $1.author, body: $1.body, createdAt: $1.createdAt, deletedAt: $1.deletedAt,
        id: $0) }
    )
  }
}
