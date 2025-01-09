import Foundation

public struct PledgePaymentIncrement: Equatable, Decodable {
  public let amount: PledgePaymentIncrementAmount
  public let scheduledCollection: TimeInterval
  public var state: String

  public init(amount: PledgePaymentIncrementAmount, scheduledCollection: TimeInterval, state: String) {
    self.amount = amount
    self.scheduledCollection = scheduledCollection
    self.state = state
  }
}

public struct PledgePaymentIncrementAmount: Equatable, Decodable {
  public let amount: Double
  public let currency: String

  public init(amount: Double, currency: String) {
    self.amount = amount
    self.currency = currency
  }
}
