import Foundation
import KsApi

public func featureNativeCheckoutEnabled() -> Bool {
  // Show native checkout only if the `ios_native_checkout` flag is enabled
  return AppEnvironment.current.config?.features[Feature.checkout.rawValue] == .some(true)
}
