import Prelude

extension GraphBackingEnvelope {
  public static let template = GraphBackingEnvelope(
    backings: GraphBackingConnection(nodes: [GraphBacking.template, GraphBacking.errored])
  )

  public static let erroredBackings = GraphBackingEnvelope(
    backings: GraphBackingConnection(nodes: [GraphBacking.errored])
  )
}
