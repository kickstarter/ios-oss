import Prelude

protocol Queryable {
  var query: NonEmptySet<Query> { get }
}

public enum UserQueries: Queryable {
  case chosenCurrency

  public var query: NonEmptySet<Query> {
    switch self {
    case .chosenCurrency:
      return NonEmptySet(Query.user(chosenCurrencyQueryFields()))
    }
  }
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
}
