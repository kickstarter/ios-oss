import Foundation
import KsApi

public func featureNativeCheckoutIsEnabled() -> Bool {
  return Feature.nativeCheckout.isEnabled()
}

public func featureNativeCheckoutPledgeViewIsEnabled() -> Bool {
  // native checkout pledge view is currently not available in release builds
  guard !AppEnvironment.current.mainBundle.isRelease else { return false }

  return Feature.nativeCheckoutPledgeView.isEnabled()
}

extension Feature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let features = environment.config?.features, !features.isEmpty else { return false }

    return features[self.rawValue] == .some(true)
  }
}
