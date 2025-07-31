import Foundation

public struct PledgePaymentIncrement: Equatable, Decodable {
  public let amount: PledgePaymentIncrementAmount
  public let scheduledCollection: TimeInterval
  public var state: PledgePaymentIncrementState
  public var stateReason: PledgePaymentIncrementStateReason?
  public let refundStatus: RefundStatus

  public init(
    amount: PledgePaymentIncrementAmount,
    scheduledCollection: TimeInterval,
    state: PledgePaymentIncrementState,
    stateReason: PledgePaymentIncrementStateReason?,
    refundStatus: RefundStatus
  ) {
    self.amount = amount
    self.scheduledCollection = scheduledCollection
    self.state = state
    self.stateReason = stateReason
    self.refundStatus = refundStatus
  }
}

public struct PledgePaymentIncrementAmount: Equatable, Decodable {
  public let currency: String
  public let amountFormattedInProjectNativeCurrency: String

  public init(
    currency: String,
    amountFormattedInProjectNativeCurrency: String
  ) {
    self.currency = currency
    self.amountFormattedInProjectNativeCurrency = amountFormattedInProjectNativeCurrency
  }
}

public enum PledgePaymentIncrementState: String, Decodable {
  case collected = "COLLECTED"
  case errored = "ERRORED"
  case unattempted = "UNATTEMPTED"
  case cancelled = "CANCELLED"
  case refunded = "REFUNDED"
}

public enum PledgePaymentIncrementStateReason: String, Decodable {
  case requiresAction = "REQUIRES_ACTION"
}

// MARK: - PledgePaymentIncrement.RefundStatus

extension PledgePaymentIncrement {
  /// Represents the refund status of a payment increment.
  public enum RefundStatus: Equatable, Decodable {
    /// No refund has been issued for this payment increment.
    case notRefunded
    /// A refund has been issued for this payment increment, with the associated amount.
    case refunded(PledgePaymentIncrementAmount)
    /// The refund status could not be determined (e.g. data not fetched).
    case unknown
  }
}
