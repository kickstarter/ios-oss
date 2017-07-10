import Prelude

extension SurveyResponse {
  public enum lens {
    public static let answeredAt = Lens<SurveyResponse, TimeInterval?>(
      view: { $0.answeredAt },
      set: { .init(answeredAt: $0, id: $1.id, project: $1.project, urls: $1.urls) }
    )

    public static let id = Lens<SurveyResponse, Int>(
      view: { $0.id },
      set: { .init(answeredAt: $1.answeredAt, id: $0, project: $1.project, urls: $1.urls) }
    )

    public static let project = Lens<SurveyResponse, Project?>(
      view: { $0.project },
      set: { .init(answeredAt: $1.answeredAt, id: $1.id, project: $0, urls: $1.urls) }
    )
  }
}
