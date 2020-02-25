import Foundation

public struct ProjectCreatorDetailsEnvelope {
  public let id: String
  public let lastLogin: TimeInterval
  public let launchedProjectsCount: Int
}

extension ProjectCreatorDetailsEnvelope: Decodable {
  private enum CodingKeys: String, CodingKey {
    case creator
    case id
    case lastLogin
    case launchedProjects
    case project
    case totalCount
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .project)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .creator)

    self.id = try values.decode(String.self, forKey: .id)
    self.lastLogin = try values.decode(TimeInterval.self, forKey: .lastLogin)
    self.launchedProjectsCount = try values
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .launchedProjects)
      .decode(Int.self, forKey: .totalCount)
  }
}
