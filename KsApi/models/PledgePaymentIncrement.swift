import Foundation

public struct PledgePaymentIncrement: Equatable, Decodable {
  public internal(set) var amount: PledgePaymentIncrementAmount
  public internal(set) var scheduledCollection: TimeInterval
  public internal(set) var stateBadgeName: String?
  public internal(set) var stateBadgeStyle: String? // TODO: should be an enum

  public init(
    amount: PledgePaymentIncrementAmount,
    scheduledCollection: TimeInterval,
    stateBadgeName: String?,
    stateBadgeStyle: String?
  ) {
    self.amount = amount
    self.scheduledCollection = scheduledCollection
    self.stateBadgeName = stateBadgeName
    self.stateBadgeStyle = stateBadgeStyle
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
