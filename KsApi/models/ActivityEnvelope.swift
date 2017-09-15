import Argo
import Curry
import Runes

public struct ActivityEnvelope {
  public private(set) var activities: [Activity]
  public private(set) var urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public private(set) var api: ApiEnvelope

    public struct ApiEnvelope {
      public private(set) var moreActivities: String
    }
  }
}

extension ActivityEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope> {
    return curry(ActivityEnvelope.init)
      <^> json <|| "activities"
      <*> json <|  "urls"
  }
}

extension ActivityEnvelope.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope.UrlsEnvelope> {
    return curry(ActivityEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension ActivityEnvelope.UrlsEnvelope.ApiEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(ActivityEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_activities" <|> .success(""))
  }
}
