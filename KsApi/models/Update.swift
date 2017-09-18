import Foundation
import Argo
import Curry
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

extension Update: Equatable {
}
public func == (lhs: Update, rhs: Update) -> Bool {
  return lhs.id == rhs.id
}

extension Update: Argo.Decodable {

  public static func decode(_ json: JSON) -> Decoded<Update> {
    let create = curry(Update.init)
    let tmp1 = create
      <^> json <|?  "body"
      <*> json <|? "comments_count"
      <*> json <|? "has_liked"
    let tmp2 = tmp1
      <*> json <|  "id"
      <*> json <|  "public"
      <*> json <|? "likes_count"
    let tmp3 = tmp2
      <*> json <|  "project_id"
      <*> json <|? "published_at"
      <*> json <|  "sequence"
      <*> (json <| "title" <|> .success(""))
    return tmp3
      <*> json <|  "urls"
      <*> json <|? "user"
      <*> json <|?  "visible"
  }
}

extension Update.UrlsEnvelope: Argo.Decodable {
  static public func decode(_ json: JSON) -> Decoded<Update.UrlsEnvelope> {
    return curry(Update.UrlsEnvelope.init)
      <^> json <| "web"
  }
}

extension Update.UrlsEnvelope.WebEnvelope: Argo.Decodable {
  static public func decode(_ json: JSON) -> Decoded<Update.UrlsEnvelope.WebEnvelope> {
    return curry(Update.UrlsEnvelope.WebEnvelope.init)
      <^> json <| "update"
  }
}
