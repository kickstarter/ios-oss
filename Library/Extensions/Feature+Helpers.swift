import Foundation
import KsApi

public func featureNativeCheckoutIsEnabled() -> Bool {
  return Feature.nativeCheckout.isEnabled()
}

public func featureNativeCheckoutPledgeViewIsEnabled() -> Bool {
  return Feature.nativeCheckoutPledgeView.isEnabled()
    && !AppEnvironment.current.mainBundle.isRelease // disables native checkout pledge view on Release build
}

extension Feature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let features = environment.config?.features, !features.isEmpty else { return false }

    return features[self.rawValue] == .some(true)
  }
}
