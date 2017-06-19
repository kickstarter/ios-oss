import Argo
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

extension ActivityEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope> {
    return curry(ActivityEnvelope.init)
      <^> json <|| "activities"
      <*> json <|  "urls"
  }
}

extension ActivityEnvelope.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope.UrlsEnvelope> {
    return curry(ActivityEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension ActivityEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(ActivityEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_activities" <|> .success(""))
  }
}
