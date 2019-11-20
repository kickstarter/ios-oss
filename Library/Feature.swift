import Foundation

public enum Feature: String {
  case goRewardless = "ios_go_rewardless"
  case nativeCheckout = "ios_native_checkout"
  case nativeCheckoutPledgeView = "ios_native_checkout_pledge_view"
}

extension Feature: CustomStringConvertible {
  public var description: String {
    switch self {
    case .goRewardless: return "Go Rewardless"
    case .nativeCheckout: return "Native Checkout"
    case .nativeCheckoutPledgeView: return "Native Checkout Pledge View"
    }
  }
}
