import Argo
import Curry
import Runes

public struct ProjectActivityEnvelope {
  public let activities: [Activity]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreActivities: String
    }
  }
}

extension ProjectActivityEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectActivityEnvelope> {
    return curry(ProjectActivityEnvelope.init)
      <^> json <|| "activities"
      <*> json <|  "urls"
  }
}

extension ProjectActivityEnvelope.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectActivityEnvelope.UrlsEnvelope> {
    return curry(ProjectActivityEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_activities" <|> .success(""))
  }
}
