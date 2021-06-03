import Foundation

public struct Comment {
  public var author: Author
  public var authorBadges: [AuthorBadge]
  public var body: String
  public let createdAt: TimeInterval
  public var id: String
  public var isDeleted: Bool
  public var isFailed: Bool = false
  public var replyCount: Int

  /// return the first `authorBadges`, if nil  return `.backer`
  public var authorBadge: AuthorBadge {
    return self.authorBadges.first ?? .backer
  }

  /// return the current status of the `Comment`
  public var status: Status {
    return self.isDeleted ? .removed : self.isFailed ? .failed : .success
  }

  public struct Author: Decodable, Equatable {
    public var id: String
    public var imageUrl: String
    public var isCreator: Bool
    public var name: String
  }

  public enum AuthorBadge: String, Decodable {
    case creator
    case backer
    case superbacker
    case you
  }

  public enum Status {
    case failed
    case removed
    case success
  }
}

extension Comment: Decodable {}

extension Comment {
  public static func createFailableComment(
    project: Project,
    user: User,
    body: String
  ) -> Comment {
    let author = Author(
      id: "\(user.id)",
      imageUrl: user.avatar.medium,
      isCreator: project.creator == user,
      name: user.name
    )
    return Comment(
      author: author,
      authorBadges: [.you],
      body: body,
      createdAt: Date().timeIntervalSince1970,
      id: UUID().uuidString,
      isDeleted: false,
      replyCount: 0
    )
  }
}

extension Comment: Equatable {}

public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}
