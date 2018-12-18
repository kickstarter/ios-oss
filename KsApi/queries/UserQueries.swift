import Prelude

public enum UserQueries: Queryable {
  case account
  case chosenCurrency
  case email
  case storedCards

  public var query: NonEmptySet<Query> {
    switch self {
    case .account:
      return NonEmptySet(Query.user(accountQueryFields()))
    case .chosenCurrency:
      return NonEmptySet(Query.user(chosenCurrencyQueryFields()))
    case .email:
      return NonEmptySet(Query.user(changeEmailQueryFields()))
    case .storedCards:
      return NonEmptySet(Query.user(storedCardsQueryFields()))
    }
  }
}

public func accountQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| [.isEmailVerified, .isEmailDeliverable, .hasPassword]
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
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
