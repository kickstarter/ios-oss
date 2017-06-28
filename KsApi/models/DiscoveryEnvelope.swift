import Argo
import Curry
import Runes

public struct DiscoveryEnvelope {
  public let projects: [Project]
  public let urls: UrlsEnvelope
  public let stats: StatsEnvelope

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreProjects: String

      public init(more_projects: String) {
        moreProjects = more_projects
      }
    }
  }

  public struct StatsEnvelope {
    public let count: Int
  }
}

extension DiscoveryEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<DiscoveryEnvelope> {
    return curry(DiscoveryEnvelope.init)
      <^> json <|| "projects"
      <*> json <|  "urls"
      <*> json <| "stats"
  }
}

extension DiscoveryEnvelope.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<DiscoveryEnvelope.UrlsEnvelope> {
    return curry(DiscoveryEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> json <| "more_projects"
  }
}

extension DiscoveryEnvelope.StatsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<DiscoveryEnvelope.StatsEnvelope> {
    return curry(DiscoveryEnvelope.StatsEnvelope.init)
      <^> json <| "count"
  }
}
