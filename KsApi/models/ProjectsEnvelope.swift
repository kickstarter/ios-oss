import Curry
import Runes

public struct ProjectsEnvelope: Swift.Decodable {
  public let projects: [Project]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Swift.Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreProjects: String
    }
  }
}

extension ProjectsEnvelope.UrlsEnvelope.ApiEnvelope: Swift.Decodable {
  enum CodingKeys: String, CodingKey {
    case moreProjects = "more_projects"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.moreProjects = try values.decodeIfPresent(String.self, forKey: .moreProjects) ?? ""
  }
}

/*
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
 */
