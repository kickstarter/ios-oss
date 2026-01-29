

public struct StarEnvelope {
  public let user: User
  public let project: Project
}

extension StarEnvelope: Decodable {}
