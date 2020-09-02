import Foundation

struct GraphBackingEnvelope: Swift.Decodable {
  var backings: GraphBackingConnection

  struct GraphBackingConnection: Swift.Decodable {
    let nodes: [GraphBacking]
  }
}
