import Prelude

public enum UserQueries: Queryable {
  case account
  case backings(String)
  case email
  case storedCards

  public var query: NonEmptySet<Query> {
    switch self {
    case .account:
      return NonEmptySet(Query.user(accountQueryFields()))
    case let .backings(status):
      return NonEmptySet(Query.user(backingsQueryFields(status: status)))
    case .email:
      return NonEmptySet(Query.user(changeEmailQueryFields()))
    case .storedCards:
      return NonEmptySet(Query.user(storedCardsQueryFields()))
    }
  }
}

public func accountQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +|
    [
      .isAppleConnected,
      .isEmailVerified,
      .isEmailDeliverable,
      .hasPassword,
      .email
    ]
}

public func storedCardsQueryFields() -> NonEmptySet<Query.User> {
  return .id +| [
    .storedCards(
      [],
      .totalCount +| [
        .nodes(
          .id +| [
            .expirationDate,
            .lastFour,
            .type
          ]
        )
      ]
    )
  ]
}

public func changeEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| [.isEmailVerified, .isEmailDeliverable]
}

public func backingsQueryFields(status: String) -> NonEmptySet<Query.User> {
  return .id +| [
    .backings(
      status: status,
      [],
      .totalCount +| [
        .nodes(
          .status +| [
            .id,
            .errorReason,
            .project(
              .pid +| [
                .name,
                .slug,
                .finalCollectionDate
              ]
            )
          ]
        )
      ]
    )
  ]
}
