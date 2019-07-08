import Foundation
import KsApi

public func featureNativeCheckoutEnabled() -> Bool {
  return AppEnvironment.current.config?.features[Feature.checkout.rawValue] == .some(true)
}
