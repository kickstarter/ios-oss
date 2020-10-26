import Curry
import Runes

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
/*
extension DiscoveryEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<DiscoveryEnvelope> {
    return curry(DiscoveryEnvelope.init)
      <^> json <|| "projects"
      <*> json <| "urls"
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
*/
