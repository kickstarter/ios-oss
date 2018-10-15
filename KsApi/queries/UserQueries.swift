import Prelude

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
}
