import Argo
import Curry
import Runes

public struct ProjectsEnvelope {
  public private(set) var projects: [Project]
  public private(set) var urls: UrlsEnvelope

  public struct UrlsEnvelope {
    public private(set) var api: ApiEnvelope

    public struct ApiEnvelope {
      public private(set) var moreProjects: String
    }
  }
}

extension ProjectsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectsEnvelope> {
    return curry(ProjectsEnvelope.init)
      <^> json <|| "projects"
      <*> json <| "urls"
  }
}

extension ProjectsEnvelope.UrlsEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectsEnvelope.UrlsEnvelope> {
    return curry(ProjectsEnvelope.UrlsEnvelope.init)
      <^> json <| "api"
  }
}

extension ProjectsEnvelope.UrlsEnvelope.ApiEnvelope: Argo.Decodable {
  public static func decode(_ json: JSON) -> Decoded<ProjectsEnvelope.UrlsEnvelope.ApiEnvelope> {
    return curry(ProjectsEnvelope.UrlsEnvelope.ApiEnvelope.init)
      <^> (json <| "more_projects" <|> .success(""))
  }
}
