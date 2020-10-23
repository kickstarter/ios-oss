import Prelude

public func rewardAddOnSelectionViewAddOnsQuery(withProjectSlug slug: String,
                                                andGraphId id: String?) -> NonEmptySet<Query> {
  return Query.project(
    slug: slug,
    GraphProject.baseQueryProperties
      .op(Query.Project.addOns(
        [],
        NonEmptySet(.nodes(GraphReward.baseQueryProperties
            .op(NonEmptySet(Query.Reward
                .shippingRulesExpanded(
                  [.arg(.locationId(id ?? ""))], // An empty string will fetch only digital rewards
                  NonEmptySet(.nodes(.id +|
                      [.cost(Money.baseQueryProperties), .location(GraphLocation.baseQueryProperties)]))
                )))))
      ) +| [])
  ) +| []
}
