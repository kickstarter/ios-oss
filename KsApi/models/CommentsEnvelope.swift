import Argo
import Curry
import Runes

public struct CommentsEnvelope {
  public let comments: [Comment]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Swift.Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Swift.Decodable {
      public let moreComments: String
    }
  }
}

extension CommentsEnvelope: Swift.Decodable {

  enum CodingKeys: String, CodingKey {
    case comments
    case urls
  }

  public init(from decoder: Decoder) throws {
    let  values = try decoder.container(keyedBy: CodingKeys.self)
    self.comments = try values.decode([Comment].self, forKey: .comments)
    self.urls = try values.decode(UrlsEnvelope.self, forKey: .urls)
  }
}

extension CommentsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<CommentsEnvelope> {
    return curry(CommentsEnvelope.init)
      <^> json <|| "comments"
      <*> json <| "urls"
  }
}

extension CommentsEnvelope.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<CommentsEnvelope.UrlsEnvelope> {
    return curry(CommentsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension CommentsEnvelope.UrlsEnvelope.ApiEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<CommentsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(CommentsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_comments" <|> .success(""))
  }
}
