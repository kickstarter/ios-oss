

public struct DiscoveryEnvelope: Swift.Decodable {
  public let projects: [Project]
  public let urls: UrlsEnvelope
  public let stats: StatsEnvelope

  public struct UrlsEnvelope: Swift.Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreProjects: String
    }
  }

  public struct StatsEnvelope: Swift.Decodable {
    public let count: Int
  }
}

extension DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case moreProjects = "more_projects"
  }
}
