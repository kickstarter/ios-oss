import Foundation

public struct UserPledgeEnvelope: Swift.Decodable {
  public var backings: UserPledgeConnection

  public struct UserPledgeConnection: Swift.Decodable {
    public let nodes: [UserPledge]
  }
}

public struct UserPledge: Swift.Decodable {
  public var errorReason: String?
  public var status: String
  public var project: Project?

  private enum CodingKeys: String, CodingKey {
    case errorReason
    case project
    case status
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.errorReason = try? values.decode(String.self, forKey: .errorReason)
    self.project = try? values.decode(Project.self, forKey: .project)
    self.status = try values.decode(String.self, forKey: .status)
  }

  public struct Project: Swift.Decodable {
    public var id: String
    public var name: String
    public var slug: String
    public var deadlineAt: TimeInterval?
  }

  public enum Status: String, CaseIterable {
    case canceled
    case collected
    case dropped
    case errored
    case pledged
    case preauth
  }
}
