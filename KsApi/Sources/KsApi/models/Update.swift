
import Foundation

public struct Update {
  public let body: String?
  public let commentsCount: Int?
  public let hasLiked: Bool?
  public let id: Int
  public let isPublic: Bool
  public let likesCount: Int?
  public let projectId: Int
  public let publishedAt: TimeInterval?
  public let sequence: Int
  public let title: String
  public let urls: UrlsEnvelope
  public let user: User?
  public let visible: Bool?

  public struct UrlsEnvelope {
    public let web: WebEnvelope

    public struct WebEnvelope {
      public let update: String
    }
  }
}

extension Update: Equatable {}

public func == (lhs: Update, rhs: Update) -> Bool {
  return lhs.id == rhs.id
}

extension Update: Decodable {
  enum CodingKeys: String, CodingKey {
    case body
    case commentsCount = "comments_count"
    case hasLiked = "has_liked"
    case id
    case isPublic = "public"
    case likesCount = "likes_count"
    case projectId = "project_id"
    case publishedAt = "published_at"
    case sequence
    case title
    case urls
    case user
    case visible
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.body = try values.decodeIfPresent(String.self, forKey: .body)
    self.commentsCount = try values.decodeIfPresent(Int.self, forKey: .commentsCount)
    self.hasLiked = try values.decodeIfPresent(Bool.self, forKey: .hasLiked)
    self.id = try values.decode(Int.self, forKey: .id)
    self.isPublic = try values.decode(Bool.self, forKey: .isPublic)
    self.likesCount = try values.decodeIfPresent(Int.self, forKey: .likesCount)
    self.projectId = try values.decode(Int.self, forKey: .projectId)
    self.publishedAt = try values.decodeIfPresent(TimeInterval.self, forKey: .publishedAt)
    self.sequence = try values.decode(Int.self, forKey: .sequence)
    self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    self.urls = try values.decode(Update.UrlsEnvelope.self, forKey: .urls)
    self.user = try values.decodeIfPresent(User.self, forKey: .user)
    self.visible = try values.decodeIfPresent(Bool.self, forKey: .visible)
  }
}

extension Update.UrlsEnvelope.WebEnvelope: Swift.Codable {}

extension Update.UrlsEnvelope: Swift.Codable {}
