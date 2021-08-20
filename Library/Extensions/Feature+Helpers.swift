import Foundation
import KsApi

public func featureSegmentIsEnabled() -> Bool {
  return Feature.segment.isEnabled()
}

extension Feature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let features = environment.config?.features, !features.isEmpty else { return false }

    return features[self.rawValue] == .some(true)
  }
}
