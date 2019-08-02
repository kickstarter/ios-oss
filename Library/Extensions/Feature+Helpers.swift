import Foundation
import KsApi

public func featureNativeCheckoutEnabled() -> Bool {
  return AppEnvironment.current.config?.features[Feature.nativeCheckout.rawValue] == .some(true)
}

public func featureNativeCheckoutPledgeViewEnabled() -> Bool {
  return AppEnvironment.current.config?.features[Feature.nativeCheckoutPledgeView.rawValue] == .some(true)
}
