import Foundation

public struct Comment {
  public var author: Author
  public var authorBadges: [AuthorBadge]
  public var body: String
  public let createdAt: TimeInterval
  public var id: String
  public var isDeleted: Bool
  public var parentId: String?
  public var replyCount: Int
  /// return the first `authorBadges`, if nil  return `.backer`
  public var authorBadge: AuthorBadge {
    return self.authorBadges.first ?? .backer
  }

  /// Use to determine if a comment is a reply to another comment
  public var isReply: Bool {
    return self.parentId != nil
  }

  /// Track and return the current status of the `Comment`
  public var status: Status = .unknown

  public struct Author: Decodable, Equatable {
    public var id: String
    public var imageUrl: String
    public var isCreator: Bool
    public var name: String
  }

  public enum AuthorBadge: String, Decodable {
    case collaborator
    case creator
    case backer
    case superbacker
    case you
  }

  public enum Status: String, Decodable {
    case failed
    case retrying
    case retrySuccess
    case success
    case unknown // Before a status is set
  }
}

extension Comment: Decodable {}

extension Comment {
  public static func failableComment(
    withId id: String,
    date: Date,
    project: Project,
    parentId: String?,
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
      createdAt: date.timeIntervalSince1970,
      id: id,
      isDeleted: false,
      parentId: parentId,
      replyCount: 0,
      status: .success
    )
  }

  public func updatingStatus(to status: Comment.Status) -> Comment {
    var comment = self
    comment.status = status
    return comment
  }
}

extension Comment: Equatable {}
