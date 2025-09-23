// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum PaymentIncrementStateReason: String, EnumType {
  /// The increment was adjusted due to a refund
  case refundAdjusted = "REFUND_ADJUSTED"
  /// The payment source has attempted to be charged, but issuer requires additional authentication to complete the payment
  case requiresAction = "REQUIRES_ACTION"
}
