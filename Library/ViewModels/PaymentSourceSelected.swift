import Foundation
public enum PaymentSourceSelected: Equatable {
  case paymentSourceId(String)
  case setupIntentClientSecret(String)
  case paymentIntentClientSecret(String)

  public var paymentSourceId: String? {
    switch self {
    case let .paymentSourceId(value):
      return value
    default:
      return nil
    }
  }

  public var setupIntentClientSecret: String? {
    switch self {
    case let .setupIntentClientSecret(value):
      return value
    default:
      return nil
    }
  }

  public var paymentIntentClientSecret: String? {
    switch self {
    case let .paymentIntentClientSecret(value):
      return value
    default:
      return nil
    }
  }
}
