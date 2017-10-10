import Foundation
import Argo
import Curry
import Runes

public struct Update {
  public private(set) var body: String?
  public private(set) var commentsCount: Int?
  public private(set) var hasLiked: Bool?
  public private(set) var id: Int
  public private(set) var isPublic: Bool
  public private(set) var likesCount: Int?
  public private(set) var projectId: Int
  public private(set) var publishedAt: TimeInterval?
  public private(set) var sequence: Int
  public private(set) var title: String
  public private(set) var urls: UrlsEnvelope
  public private(set) var user: User?
  public private(set) var visible: Bool?

  public struct UrlsEnvelope {
    public private(set) var web: WebEnvelope

    public struct WebEnvelope {
      public private(set) var update: String
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
