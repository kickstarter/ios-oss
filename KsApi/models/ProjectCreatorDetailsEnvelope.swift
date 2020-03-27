import Foundation

public struct ProjectCreatorDetailsEnvelope: Equatable {
  public let backingsCount: Int
  public let id: String
  public let launchedProjectsCount: Int
}

extension ProjectCreatorDetailsEnvelope: Decodable {
  private enum CodingKeys: String, CodingKey {
    case backingsCount
    case creator
    case id
    case launchedProjects
    case project
    case totalCount
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .project)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .creator)

    self.backingsCount = try values
      .decode(Int.self, forKey: .backingsCount)
    self.id = try values.decode(String.self, forKey: .id)
    self.launchedProjectsCount = try values
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .launchedProjects)
      .decode(Int.self, forKey: .totalCount)
  }
}
