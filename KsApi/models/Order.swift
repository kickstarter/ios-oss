import Foundation

public struct Order: Equatable, Decodable {
  public let checkoutState: CheckoutState
  public let currency: String
  public let total: Int?

  public init(
    checkoutState: CheckoutState,
    currency: String,
    total: Int?
  ) {
    self.checkoutState = checkoutState
    self.currency = currency
    self.total = total
  }
}

public enum CheckoutState: String, Decodable {
  case complete
  case inProgress = "in_progress"
  case notStarted = "not_started"
}

extension Order {
  public init?(withGraphQLFragment fragment: GraphAPI.OrderFragment) {
    guard let checkoutState = CheckoutState(rawValue: fragment.checkoutState.rawValue) else {
      return nil
    }

    self.checkoutState = checkoutState
    self.currency = fragment.currency.rawValue
    self.total = fragment.total
  }
}
