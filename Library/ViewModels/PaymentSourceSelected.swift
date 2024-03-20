import Foundation
public enum PaymentSourceSelected: Equatable {
  case paymentSourceId(String)
  case setupIntentClientSecret(String)

  public var paymentSourceId: String? {
    if case let .paymentSourceId(value) = self {
      return value
    } else {
      return nil
    }
  }

  public var setupIntentClientSecret: String? {
    if case let .setupIntentClientSecret(value) = self {
      return value
    } else {
      return nil
    }
  }
}
