import Prelude

public func rewardAddOnSelectionViewAddOnsQuery(withProjectSlug slug: String,
                                                andGraphId id: String?) -> NonEmptySet<Query> {
  var shippingRulesExpandedArg: Set<QueryArg<Query.Reward.ShippingRulesExpandedConnection.Argument>>

  if let graphID = id {
    shippingRulesExpandedArg = [.arg(.locationId(graphID))]
  } else {
    shippingRulesExpandedArg = []
  }

  return Query.project(
    slug: slug,
    GraphProject.baseQueryProperties
      .op(Query.Project.addOns(
        [],
        NonEmptySet(.nodes(GraphReward.baseQueryProperties
            .op(NonEmptySet(Query.Reward
                .shippingRulesExpanded(
                  shippingRulesExpandedArg,
                  NonEmptySet(.nodes(.id +|
                      [.cost(Money.baseQueryProperties), .location(GraphLocation.baseQueryProperties)]))
                )))))
      ) +| [])
  ) +| []
}
