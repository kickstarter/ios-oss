import Foundation

/* PledgePaymentMethodsViewController used to return multiple types of selected payments.
 Now it can only return stored credit cards. Leaving this enum here in case we ever add
 more payment types in the future.
 */

public typealias StripePaymentMethodID = String
public typealias KSRCreditCardId = String
public enum PaymentSourceSelected: Equatable {
  case savedCreditCard(KSRCreditCardId, StripePaymentMethodID?)

  public var savedCreditCardId: KSRCreditCardId {
    switch self {
    case let .savedCreditCard(savedCardId, _):
      return savedCardId
    }
  }

  public var stripePaymentMethodId: StripePaymentMethodID? {
    switch self {
    case let .savedCreditCard(_, paymentMethodId):
      return paymentMethodId
    }
  }
}
