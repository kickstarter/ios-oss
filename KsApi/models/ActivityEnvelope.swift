import Curry
import Runes

public struct ActivityEnvelope {
  public let activities: [Activity]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Swift.Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope: Swift.Decodable {
      public let moreActivities: String
    }
  }
}

extension ActivityEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case activities = "activities"
    case urls = "urls"
  }
}
/*
extension ActivityEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ActivityEnvelope> {
    return curry(ActivityEnvelope.init)
      <^> json <|| "activities"
      <*> json <| "urls"
  }
}
*/
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
