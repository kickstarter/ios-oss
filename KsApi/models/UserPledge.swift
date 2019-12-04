import Foundation

public struct GraphBackingEnvelope: Swift.Decodable {
  public var backings: GraphBackingConnection

  public struct GraphBackingConnection: Swift.Decodable {
    public let nodes: [GraphBacking]
  }
}

public struct GraphBacking: Swift.Decodable {
  public var errorReason: String?
  public var project: Project?
  public var status: Status

  public struct Project: Swift.Decodable {
    public var id: String
    public var name: String
    public var slug: String
    public var deadlineAt: TimeInterval?
  }

  public enum Status: String, CaseIterable, Swift.Decodable {
    case canceled
    case collected
    case dropped
    case errored
    case pledged
    case preauth
  }
}
