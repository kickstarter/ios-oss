import Foundation

public enum Feature: String {
  case nativeCheckout = "ios_native_checkout"
  case nativeCheckoutPledgeView = "ios_native_checkout_pledge_view"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .nativeCheckout: return "Native Checkout"
    case .nativeCheckoutPledgeView: return "Native Checkout Pledge View"
    }
  }
}
