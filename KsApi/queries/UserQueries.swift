import Prelude

public enum UserQueries: Queryable {
  case chosenCurrency
  case email
  case storedCards

  public var query: NonEmptySet<Query> {
    switch self {
    case .chosenCurrency:
      return NonEmptySet(Query.user(chosenCurrencyQueryFields()))
    case .email:
      return NonEmptySet(Query.user(userEmailQueryFields()))
    case .storedCards:
      return NonEmptySet(Query.user(storedCardsQueryFields()))
    }
  }
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
}

public func userEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| []
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
