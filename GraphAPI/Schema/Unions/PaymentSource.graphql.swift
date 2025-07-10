// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension GraphAPI.Unions {
  /// Payment sources
  static let PaymentSource = Union(
    name: "PaymentSource",
    possibleTypes: [
      GraphAPI.Objects.BankAccount.self,
      GraphAPI.Objects.CreditCard.self
    ]
  )
}