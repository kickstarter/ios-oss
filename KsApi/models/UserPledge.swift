import Foundation

public struct UserPledgeEnvelope: Swift.Decodable {
  public var backings: UserPledgeConnection

  public struct UserPledgeConnection: Swift.Decodable {
    public let nodes: [UserPledge]?
    public let totalCount: Int
  }
}

public struct UserPledge: Swift.Decodable {
  public var errorReason: String?
  public var project: Project?
  public var status: String

  public struct Project: Swift.Decodable {
    public var deadlineAt: TimeInterval?
    public var id: String
    public var name: String
    public var slug: String
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
