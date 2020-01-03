import Foundation
import KsApi

public func featureGoRewardlessIsEnabled() -> Bool {
  return Feature.goRewardless.isEnabled()
}

public func featureNativeCheckoutIsEnabled() -> Bool {
  return Feature.nativeCheckout.isEnabled()
}

public func featureNativeCheckoutPledgeViewIsEnabled() -> Bool {
  return Feature.nativeCheckoutPledgeView.isEnabled()
}

public func featureQualtricsIsEnabled() -> Bool {
  return Feature.qualtrics.isEnabled()
}

extension Feature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let features = environment.config?.features, !features.isEmpty else { return false }

    return features[self.rawValue] == .some(true)
  }
}
