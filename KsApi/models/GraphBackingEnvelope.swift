import Foundation

public struct GraphBackingEnvelope: Swift.Decodable {
  public var backings: GraphBackingConnection

  public struct GraphBackingConnection: Swift.Decodable {
    public let nodes: [GraphBacking]
  }
}
