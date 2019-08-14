import Foundation
import KsApi

public func userCanSeeNativeCheckout() -> Bool {
  return Experiment.Name.nativeCheckoutV1.isEnabled() && featureNativeCheckoutEnabled()
}

public func featureNativeCheckoutEnabled() -> Bool {
  return Feature.nativeCheckout.isEnabled()
}

public func featureNativeCheckoutPledgeViewEnabled() -> Bool {
  return Feature.nativeCheckoutPledgeView.isEnabled()
}
