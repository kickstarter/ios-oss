import Foundation
import KsApi

public func featureQualtricsIsEnabled() -> Bool {
  return Feature.qualtrics.isEnabled()
}

public func featureEmailVerificationFlowIsEnabled() -> Bool {
  return Feature.emailVerificationFlow.isEnabled()
}

public func featureEmailVerificationSkipIsEnabled() -> Bool {
  return Feature.emailVerificationSkip.isEnabled()
}

extension Feature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let features = environment.config?.features, !features.isEmpty else { return false }

    return features[self.rawValue] == .some(true)
  }
}
