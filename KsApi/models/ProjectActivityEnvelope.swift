import Argo
import Curry
import Runes

public struct ProjectActivityEnvelope {
  public private(set) var activities: [Activity]
  public private(set) var urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public private(set) var api: ApiEnvelope

    public struct ApiEnvelope {
      public private(set) var moreActivities: String
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
