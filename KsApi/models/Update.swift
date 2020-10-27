import Curry
import Foundation
import Runes

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

extension Update: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case body = "body"
    case commentsCount = "comments_count"
    case hasLiked = "has_liked"
    case id = "id"
    case isPublic = "public"
    case likesCount = "likes_count"
    case projectId = "project_id"
    case publishedAt = "published_at"
    case sequence = "sequence"
    case title = "title"
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

extension Update: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Update> {
    let tmp1 = curry(Update.init)
      <^> json <|? "body"
      <*> json <|? "comments_count"
      <*> json <|? "has_liked"
    let tmp2 = tmp1
      <*> json <| "id"
      <*> json <| "public"
      <*> json <|? "likes_count"
    let tmp3 = tmp2
      <*> json <| "project_id"
      <*> json <|? "published_at"
      <*> json <| "sequence"
      <*> (json <| "title" <|> .success(""))
    
    return tmp3
      <*> ((json <| "urls" >>- tryDecodable) as Decoded<Update.UrlsEnvelope>)
      <*> ((json <|? "user" >>- tryDecodable) as Decoded<User?>)
      <*> json <|? "visible"
  }
}

extension Update.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Update.UrlsEnvelope> {
    return curry(Update.UrlsEnvelope.init)
      <^> json <| "web"
  }
}

extension Update.UrlsEnvelope.WebEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<Update.UrlsEnvelope.WebEnvelope> {
    return curry(Update.UrlsEnvelope.WebEnvelope.init)
      <^> json <| "update"
  }
}

extension Update.UrlsEnvelope.WebEnvelope: Swift.Codable {}

extension Update.UrlsEnvelope: Swift.Codable {}
