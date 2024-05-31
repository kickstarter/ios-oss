import Foundation

/* PledgePaymentMethodsViewController used to return multiple types of selected payments.
 Now it can only return stored credit cards. Leaving this enum here in case we ever add
 more payment types in the future.
 */
public enum PaymentSourceSelected: Equatable {
  case savedCreditCard(String)

  public var savedCreditCardId: String? {
    switch self {
    case let .savedCreditCard(value):
      return value
    }
  }
}
