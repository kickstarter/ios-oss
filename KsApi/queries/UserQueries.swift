import Prelude

public enum UserQueries: Queryable {
  case account
  case chosenCurrency
  case email

  public var query: NonEmptySet<Query> {
    switch self {
    case .account:
      return NonEmptySet(Query.user(accountQueryFields()))
    case .chosenCurrency:
      return NonEmptySet(Query.user(chosenCurrencyQueryFields()))
    case .email:
      return NonEmptySet(Query.user(userEmailQueryFields()))
    }
  }
}

public func accountQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| [.isEmailVerified, .isEmailDeliverable]
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
}

public func userEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| []
}

public func changeEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| [.isEmailVerified, .isEmailDeliverable]
}
