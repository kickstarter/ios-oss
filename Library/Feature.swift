import Foundation

public enum Feature: String {
  case testFeature = "test_feature" // This case is used only for tests. Please, do not delete!
  case nativeCheckout = "ios_native_checkout"
  case nativeCheckoutPledgeView = "ios_native_checkout_pledge_view"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .nativeCheckout: return "Native Checkout"
    case .nativeCheckoutPledgeView: return "Native Checkout Pledge View"
    case .testFeature: return "Test Feature"
    }
  }
}
