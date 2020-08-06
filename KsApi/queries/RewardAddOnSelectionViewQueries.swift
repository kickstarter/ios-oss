import Prelude

public func rewardAddOnSelectionViewAddOnsQuery(withProjectSlug slug: String) -> NonEmptySet<Query> {
  return Query.project(
    slug: slug,
    GraphProject.baseQueryProperties
      .op(Query.Project.addOns([], NonEmptySet(.nodes(GraphReward.baseQueryProperties))) +| [])
  ) +| []
}
