import Argo
import Curry
import Runes

public struct ProjectsEnvelope {
  public let projects: [Project]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreProjects: String
    }
  }
}

extension ProjectsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectsEnvelope> {
    return curry(ProjectsEnvelope.init)
      <^> json <|| "projects"
      <*> json <| "urls"
  }
}

extension ProjectsEnvelope.UrlsEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectsEnvelope.UrlsEnvelope> {
    return curry(ProjectsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension ProjectsEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(ProjectsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_projects" <|> .success(""))
  }
}
