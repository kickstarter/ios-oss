import Foundation

struct GraphBackingEnvelope: Decodable {
  var backings: GraphBackingConnection

  struct GraphBackingConnection: Decodable {
    let nodes: [GraphBacking]
  }
}
