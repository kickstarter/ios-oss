

public struct ProjectActivityEnvelope: Decodable {
  public let activities: [Activity]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Decodable {
      private enum CodingKeys: String, CodingKey {
        case moreActivities = "more_activities"
      }

      public let moreActivities: String
    }
  }
}
