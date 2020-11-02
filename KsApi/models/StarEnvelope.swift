import Curry
import Runes

public struct StarEnvelope {
  public let user: User
  public let project: Project
}

extension StarEnvelope: Swift.Decodable {}
