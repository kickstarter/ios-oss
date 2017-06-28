import Argo
import Curry
import Runes

public struct SurveyResponse {
  public let answeredAt: TimeInterval?
  public let id: Int
  public let project: Project?
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public let web: WebEnvelope

    public struct WebEnvelope {
      public let survey: String
    }
  }
}

extension SurveyResponse: Equatable {}
public func == (lhs: SurveyResponse, rhs: SurveyResponse) -> Bool {
  return lhs.id == rhs.id
}

extension SurveyResponse: Decodable {
  public static func decode(_ json: JSON) -> Decoded<SurveyResponse> {
    return curry(SurveyResponse.init)
      <^> json <|? "answered_at"
      <*> json <| "id"
      <*> json <|? "project"
      <*> json <| "urls"
  }
}

extension SurveyResponse.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<SurveyResponse.UrlsEnvelope> {
    return curry(SurveyResponse.UrlsEnvelope.init)
      <^> json <| "web"
  }
}

extension SurveyResponse.UrlsEnvelope.WebEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<SurveyResponse.UrlsEnvelope.WebEnvelope> {
    return curry(SurveyResponse.UrlsEnvelope.WebEnvelope.init)
      <^> json <| "survey"
  }
}
