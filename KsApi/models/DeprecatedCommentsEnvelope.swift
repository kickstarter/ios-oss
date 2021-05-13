

public struct DeprecatedCommentsEnvelope: Decodable {
  public let comments: [DeprecatedComment]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Decodable {
      public let moreComments: String
    }
  }
}

extension DeprecatedCommentsEnvelope.UrlsEnvelope {
  enum CodingKeys: String, CodingKey {
    case api
    case moreComments = "more_comments"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    do {
      let moreComments = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .api)
        .decode(String.self, forKey: .moreComments)
      self.api = DeprecatedCommentsEnvelope.UrlsEnvelope.ApiEnvelope(moreComments: moreComments)
    } catch {
      self.api = DeprecatedCommentsEnvelope.UrlsEnvelope.ApiEnvelope(moreComments: "")
    }
  }
}
