import Foundation
import KsApi

public func userCanSeeNativeCheckout() -> Bool {
  return experimentNativeCheckoutIsEnabled() && featureNativeCheckoutIsEnabled()
}
