import Prelude

public func baseUserQueryFields() -> NonEmptySet<Query.User> {
  return .id +| [.userId, .name]
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return baseUserQueryFields().op(.chosenCurrency +| [])
}
