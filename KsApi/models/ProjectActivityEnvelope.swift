import Curry
import Runes

public struct ProjectActivityEnvelope: Swift.Decodable {
  public let activities: [Activity]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Swift.Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Swift.Decodable {
      public let moreActivities: String
    }
  }
}

extension ProjectActivityEnvelope.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectActivityEnvelope.UrlsEnvelope> {
    return curry(ProjectActivityEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_activities" <|> .success(""))
  }
}
