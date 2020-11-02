import Curry
import Runes

public struct ActivityEnvelope {
  public let activities: [Activity]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreActivities: String
    }
  }
}

extension ActivityEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case activities
    case urls
  }
}

extension ActivityEnvelope.UrlsEnvelope: Swift.Decodable {}

extension ActivityEnvelope.UrlsEnvelope.ApiEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case moreActivities = "more_activities"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.moreActivities = try values.decodeIfPresent(String.self, forKey: .moreActivities) ?? ""
  }
}
