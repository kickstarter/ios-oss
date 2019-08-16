import Foundation
import KsApi

public func featureNativeCheckoutEnabled() -> Bool {
  return Feature.nativeCheckout.isEnabled()
}

public func featureNativeCheckoutPledgeViewEnabled() -> Bool {
  return Feature.nativeCheckoutPledgeView.isEnabled()
}

extension Feature {
  public func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let features = environment.config?.features, !features.isEmpty else { return false }

    return AppEnvironment.current.config?.features[self.rawValue] == .some(true)
  }
}
