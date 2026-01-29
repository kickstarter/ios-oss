import Foundation

public struct PledgePaymentIncrement: Equatable, Decodable {
  public struct Badge: Equatable, Decodable {
    public enum Variant: String, Decodable {
      case purple = "PURPLE"
      case green = "GREEN"
      case red = "RED"
      case danger = "DANGER"
      case gray = "GRAY"
    }

    public internal(set) var copy: String
    public internal(set) var variant: PledgePaymentIncrement.Badge.Variant
  }

  public internal(set) var amount: PledgePaymentIncrementAmount
  /// Badge will only be set for pledge increments with a backing.
  public internal(set) var badge: PledgePaymentIncrement.Badge?
  /// Refund status will only be set for pledge increments with a backing. Otherwise, it will be `.unknown`
  public internal(set) var refundStatus: RefundStatus
  public internal(set) var scheduledCollection: TimeInterval

  public init(
    amount: PledgePaymentIncrementAmount,
    badge: PledgePaymentIncrement.Badge? = nil,
    refundStatus: RefundStatus,
    scheduledCollection: TimeInterval
  ) {
    self.amount = amount
    self.badge = badge
    self.refundStatus = refundStatus
    self.scheduledCollection = scheduledCollection
  }
}

public struct PledgePaymentIncrementAmount: Equatable, Decodable {
  public internal(set) var currency: String
  public internal(set) var amountFormattedInProjectNativeCurrency: String

  public init(
    currency: String,
    amountFormattedInProjectNativeCurrency: String
  ) {
    self.currency = currency
    self.amountFormattedInProjectNativeCurrency = amountFormattedInProjectNativeCurrency
  }
}

extension PledgePaymentIncrement {
  /// Represents the refund status of a payment increment.
  public enum RefundStatus: Equatable, Decodable {
    /// No refund has been issued for this payment increment.
    case notRefunded
    /// A refund has been issued for this payment increment.
    /// The associated `PledgePaymentIncrementAmount` equals the total collected amount,
    /// i.e. the increment minus any refunds.
    case partialRefund(PledgePaymentIncrementAmount)
    /// A full refund has been issued for this payment increment.
    case fullRefund
    /// The refund status could not be determined (e.g. data not fetched).
    case unknown
  }
}
