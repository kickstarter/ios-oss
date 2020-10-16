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
      <*> json <|? "user"
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
