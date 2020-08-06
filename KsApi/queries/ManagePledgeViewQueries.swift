import Prelude

public func managePledgeViewProjectBackingQuery(withBackingId backingId: String) -> NonEmptySet<Query> {
  return Query.backing(
    id: backingId,
    GraphBacking.baseQueryProperties
  ) +| []
}
