

public struct ProjectsEnvelope: Decodable {
  public let projects: [Project]
  public let urls: UrlsEnvelope

  public struct UrlsEnvelope: Decodable {
    public let api: ApiEnvelope

    public struct ApiEnvelope {
      public let moreProjects: String
    }
  }
}

extension ProjectsEnvelope.UrlsEnvelope.ApiEnvelope: Decodable {
  enum CodingKeys: String, CodingKey {
    case moreProjects = "more_projects"
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.moreProjects = try values.decodeIfPresent(String.self, forKey: .moreProjects) ?? ""
  }
}
