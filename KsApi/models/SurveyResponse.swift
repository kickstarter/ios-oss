import Argo
import Curry
import Runes

public struct SurveyResponse: Equatable {
  public let answeredAt: TimeInterval?
  public let id: Int
  public let project: Project?
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Equatable {
    public let web: WebEnvelope

    public struct WebEnvelope: Equatable {
      public let survey: String
    }
  }
}

extension SurveyResponse: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<SurveyResponse> {
    return curry(SurveyResponse.init)
      <^> json <|? "answered_at"
      <*> json <| "id"
      <*> json <|? "project"
      <*> json <| "urls"
  }
}

extension SurveyResponse.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<SurveyResponse.UrlsEnvelope> {
    return curry(SurveyResponse.UrlsEnvelope.init)
      <^> json <| "web"
  }
}

extension SurveyResponse.UrlsEnvelope.WebEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<SurveyResponse.UrlsEnvelope.WebEnvelope> {
    return curry(SurveyResponse.UrlsEnvelope.WebEnvelope.init)
      <^> json <| "survey"
  }
}
