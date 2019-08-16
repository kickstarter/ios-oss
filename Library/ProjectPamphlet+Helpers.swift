import Foundation
import KsApi

public func userCanSeeNativeCheckout() -> Bool {
  return nativeCheckoutExperimentIsEnabled() && featureNativeCheckoutEnabled()
}
