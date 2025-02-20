import Foundation

public struct PledgePaymentIncrement: Equatable, Decodable {
  public let amount: PledgePaymentIncrementAmount
  public let scheduledCollection: TimeInterval
  public var state: PledgePaymentIncrementState
  public var stateReason: PledgePaymentIncrementStateReason?

  public init(
    amount: PledgePaymentIncrementAmount,
    scheduledCollection: TimeInterval,
    state: PledgePaymentIncrementState,
    stateReason: PledgePaymentIncrementStateReason?
  ) {
    self.amount = amount
    self.scheduledCollection = scheduledCollection
    self.state = state
    self.stateReason = stateReason
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
}

public enum PledgePaymentIncrementStateReason: String, Decodable {
  case requiresAction = "REQUIRES_ACTION"
}
