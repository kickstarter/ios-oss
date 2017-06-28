import Argo
import Curry
import Runes

public struct CommentsEnvelope {
  public let comments: [Comment]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreComments: String
    }
  }
}

extension CommentsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<CommentsEnvelope> {
    return curry(CommentsEnvelope.init)
      <^> json <|| "comments"
      <*> json <| "urls"
  }
}

extension CommentsEnvelope.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<CommentsEnvelope.UrlsEnvelope> {
    return curry(CommentsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension CommentsEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<CommentsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(CommentsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_comments" <|> .success(""))
  }
}
