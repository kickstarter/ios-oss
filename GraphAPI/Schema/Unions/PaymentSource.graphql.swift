// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension Unions {
  /// Payment sources
  static let PaymentSource = Union(
    name: "PaymentSource",
    possibleTypes: [
      Objects.BankAccount.self,
      Objects.CreditCard.self
    ]
  )
}