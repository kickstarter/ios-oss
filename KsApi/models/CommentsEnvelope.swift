

public struct CommentsEnvelope: Decodable {
  public let comments: [Comment]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Decodable {
      public let moreComments: String
    }
  }
}

extension CommentsEnvelope.UrlsEnvelope {
  enum CodingKeys: String, CodingKey {
    case api
    case moreComments = "more_comments"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    do {
      let moreComments = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .api)
        .decode(String.self, forKey: .moreComments)
      self.api = CommentsEnvelope.UrlsEnvelope.ApiEnvelope(moreComments: moreComments)
    } catch {
      self.api = CommentsEnvelope.UrlsEnvelope.ApiEnvelope(moreComments: "")
    }
  }
}
