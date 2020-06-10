import Prelude

public func managePledgeViewProjectBackingQuery(withBackingId backingId: String) -> NonEmptySet<Query> {
  return Query.backing(
    id: backingId,
    .id +| [
      .project(
        .pid +| [
          .name,
          .state
        ]
      ),
      .status,
      .amount(
        .amount +| [
          .currency,
          .symbol
        ]
      ),
      .sequence,
      .cancelable,
      .backer(
        .uid +| [
          .name
        ]
      ),
      .creditCard(
        .id +| [
          .expirationDate,
          .lastFour,
          .paymentType,
          .type
        ]
      ),
      .errorReason,
      .location(.name +| []),
      .pledgedOn,
      .reward(
        .name +| [
          .id,
          .isMaxPledge,
          .amount(
            .amount +| [
              .currency,
              .symbol
            ]
          ),
          .backersCount,
          .description,
          .displayName,
          .estimatedDeliveryOn,
          .items([], NonEmptySet(.nodes(.id +| [.name])))
        ]
      ),
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
              .backersCount,
              .isMaxPledge,
              .limit,
              .items([], NonEmptySet(.nodes(.id +| [.name]))),
              .remainingQuantity,
              .startsAt
            ]
          )
        )
      )
    ]
  ) +| []
}
