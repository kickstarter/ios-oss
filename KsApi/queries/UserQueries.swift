import Prelude

public enum UserQueries: Queryable {
  case chosenCurrency
  case email

  public var query: NonEmptySet<Query> {
    switch self {
    case .chosenCurrency:
      return NonEmptySet(Query.user(chosenCurrencyQueryFields()))
    case .email:
      return NonEmptySet(Query.user(userEmailQueryFields()))
    }
  }
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
}

public func userEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| []
}

public func changeEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| [.isEmailVerified]
}
