import Foundation

/**
 FIXME: Some of the `Comment`'s properties does not represent `GraphComment` mapping but rather the expected structure.
 Some of these properties might need to be updated once `GraphComment` has the needed properties for `Comment`.
 */

public struct Comment {
  public var author: Author
  public var authorBadges: [AuthorBadge]?
  public var body: String
  public let createdAt: TimeInterval
  public let deletedAt: TimeInterval?
  public var id: String
  public var isDeleted: Bool
  public var isFailed: Bool = false
  public var uid: Int
  public var replyCount: Int

  /// return the first `authorBadges`, if nil  return `.backer`
  public var authorBadge: AuthorBadge {
    return self.authorBadges?.first ?? .backer
  }

  // return the current status of the comment
  public var status: Status {
    return self.isDeleted ? .removed : self.isFailed ? .failed : .success
  }

  public struct Author: Decodable, Equatable {
    public var id: String
    public var imageUrl: String
    public var isCreator: Bool
    public var name: String
  }

  public enum AuthorBadge: String {
    case creator
    case superbacker
    case backer
    case you // This doesn't exist on GraphComment, but would be mapped with current user id and author id
  }

  public enum Status {
    case success
    case failed
    case removed
  }
}

extension Comment: Decodable {
  enum CodingKeys: String, CodingKey {
    case author
    case authorBadges
    case body
    case createdAt = "created_at"
    case deletedAt = "deleted_at"
    case id
    case isDeleted = "deleted"
    case uid
    case replyCount
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.author = try values.decode(Author.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.id = try values.decode(String.self, forKey: .id)
    self.isDeleted = try values.decode(Bool.self, forKey: .isDeleted)
    self.uid = try values.decode(Int.self, forKey: .uid)
    self.replyCount = try values.decode(Int.self, forKey: .replyCount)

    // Decode a time interval so that non-positive values are coalesced to `nil`. We do this because the API
    // sends back `0` when the comment hasn't been deleted, and we'd rather handle that value as `nil`.
    let value = try values.decodeIfPresent(TimeInterval.self, forKey: .deletedAt) ?? 0
    self.deletedAt = value > 0 ? value : nil
  }
}

extension Comment: Equatable {}

public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}
