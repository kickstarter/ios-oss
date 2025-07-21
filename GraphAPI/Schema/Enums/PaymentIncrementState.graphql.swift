// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public enum PaymentIncrementState: String, EnumType {
  /// The initial state of the payment increment; payment source has not been charged
  case unattempted = "UNATTEMPTED"
  /// Payment source was successfully charged
  case collected = "COLLECTED"
  /// Payment source could not be charged due to an errored payment source or authentication being required
  case errored = "ERRORED"
  /// Payment increment is cancelled by user action or is an abandoned increment due to failure to complete payment
  case cancelled = "CANCELLED"
  /// Backer issued a dispute and we (kickstarter) lost the dispute
  case chargebackLost = "CHARGEBACK_LOST"
  /// Payment increment has been refunded
  case refunded = "REFUNDED"
}
