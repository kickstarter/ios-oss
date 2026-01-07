

public struct DiscoveryEnvelope: Decodable {
  public let projects: [Project]
  public let urls: UrlsEnvelope
  public let stats: StatsEnvelope

  public struct UrlsEnvelope: Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreProjects: String
    }
  }

  public struct StatsEnvelope: Decodable {
    public let count: Int
  }
}

extension DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case moreProjects = "more_projects"
  }
}
