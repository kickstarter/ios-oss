import Prelude

public func rewardAddOnSelectionViewAddOnsQuery(withProjectSlug slug: String) -> NonEmptySet<Query> {
  return Query.project(
    slug: slug,
    .pid +| [
      .fxRate,
      .actions(.displayConvertAmount +| []),
      .addOns(
        [],
        NonEmptySet(
          .nodes(
            .id +| [
              .displayName,
              .description,
              .estimatedDeliveryOn,
              .name,
              .amount(
                .amount +| [
                  .currency,
                  .symbol
                ]
              ),
              .convertedAmount(
                .amount +| [
                  .currency,
                  .symbol
                ]
              ),
              .backersCount,
              .isMaxPledge,
              .limit,
              .limitPerBacker,
              .items([], NonEmptySet(.nodes(.id +| [.name]))),
              .remainingQuantity,
              .shippingPreference,
              .shippingRules(.id +| [
                .cost(
                  .amount +| [
                    .currency,
                    .symbol
                  ]
                ),
                .location(
                  .name +| [
                    .country,
                    .countryName,
                    .displayableName,
                    .id
                  ])
              ]),
              .startsAt
            ]
          )
        )
      )
    ]
  ) +| []
}
