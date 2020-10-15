import Prelude

public func rewardAddOnSelectionViewAddOnsQuery(withProjectSlug slug: String,
                                                andLocationId locationId: Int?) -> NonEmptySet<Query> {
  var shippingRulesExpandedArg: Set<QueryArg<Query.Reward.ShippingRulesExpandedConnection.Argument>>

  if let id = locationId {
    shippingRulesExpandedArg = [.arg(.locationId(String(id)))]
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
