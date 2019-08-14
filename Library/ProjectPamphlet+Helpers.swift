import Foundation
import KsApi

public func userCanSeeNativeCheckout() -> Bool {
  return Experiment.Name.nativeCheckoutV1.isEnabled() && featureNativeCheckoutEnabled()
}
