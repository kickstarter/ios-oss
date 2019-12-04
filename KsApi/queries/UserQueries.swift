import Prelude

public enum UserQueries: Queryable {
  case account
  case email
  case pledges(String)
  case storedCards

  public var query: NonEmptySet<Query> {
    switch self {
    case .account:
      return NonEmptySet(Query.user(accountQueryFields()))
    case .email:
      return NonEmptySet(Query.user(changeEmailQueryFields()))
    case .pledges(let status):
      return NonEmptySet(Query.user(pledgesQueryFields(status: status)))
    case .storedCards:
      return NonEmptySet(Query.user(storedCardsQueryFields()))
    }
  }
}

public func accountQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| [.isEmailVerified, .isEmailDeliverable, .hasPassword, .email]
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

public func pledgesQueryFields(status: String) -> NonEmptySet<Query.User> {
  return .id +| [
    .pledges(
      status: status,
      [],
      .totalCount +| [
        .nodes(
          .status +| [
            .project(
              .id +| [
                .deadlineAt,
                .name,
                .slug
              ]
            ),
            .errorReason          ]
        )
      ]
    )
  ]
}
