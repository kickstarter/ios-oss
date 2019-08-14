import Foundation
import KsApi

public func featureNativeCheckoutEnabled() -> Bool {
  return Feature.nativeCheckout.isEnabled()
}

public func featureNativeCheckoutPledgeViewEnabled() -> Bool {
  return Feature.nativeCheckoutPledgeView.isEnabled()
}
