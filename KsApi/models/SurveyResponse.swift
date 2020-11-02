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

extension SurveyResponse: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case answeredAt = "answered_at"
    case id
    case project
    case urls
  }
}

extension SurveyResponse.UrlsEnvelope: Swift.Decodable {}
extension SurveyResponse.UrlsEnvelope.WebEnvelope: Swift.Decodable {}
