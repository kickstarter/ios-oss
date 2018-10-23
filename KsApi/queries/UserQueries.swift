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
      return NonEmptySet(Query.user(userEmailQueryFields()))
   //   return NonEmptySet(Query.user(storedCardsQueryFields()))
    }
  }
}

public func chosenCurrencyQueryFields() -> NonEmptySet<Query.User> {
  return .chosenCurrency +| []
}

public func userEmailQueryFields() -> NonEmptySet<Query.User> {
  return .email +| []
}

//public func storedCardsQueryFields() -> NonEmptySet<Query.User> {
//  return .storedCards +| [.nodes( .id, .type )]
//}

/*
 {
 "data": {
  "me": {
    "storedCards": {
      "nodes": [
    {
      "id": "51954203",
      "expirationDate": "2021-12-01",
      "lastFour": "4910",
      "type": "MASTERCARD"
    }
      ]
 }
 }
 }
 }
 */
