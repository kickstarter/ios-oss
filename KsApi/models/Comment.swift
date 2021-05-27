import Foundation

public struct Comment {
  public var author: Author
  public var authorBadges: [Author.AuthorBadge]
  public var body: String
  public let createdAt: TimeInterval
  public var id: String
  public var isDeleted: Bool
  public var isFailed: Bool = false
  public var replyCount: Int

  /// return the first `authorBadges`, if nil  return `.backer`
  public var authorBadge: Author.AuthorBadge {
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

    public enum AuthorBadge: String, Decodable {
      case creator
      case backer
      case superbacker
      case you
    }
  }

  public enum Status {
    case failed
    case removed
    case success
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
    case replyCount
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.author = try values.decode(Author.self, forKey: .author)
    self.body = try values.decode(String.self, forKey: .body)
    self.createdAt = try values.decode(TimeInterval.self, forKey: .createdAt)
    self.id = try values.decode(String.self, forKey: .id)
    self.isDeleted = try values.decode(Bool.self, forKey: .isDeleted)
    self.replyCount = try values.decode(Int.self, forKey: .replyCount)
    self.authorBadges = try values.decode([Author.AuthorBadge].self, forKey: .authorBadges)
  }
}

extension Comment: Equatable {}

public func == (lhs: Comment, rhs: Comment) -> Bool {
  return lhs.id == rhs.id
}
