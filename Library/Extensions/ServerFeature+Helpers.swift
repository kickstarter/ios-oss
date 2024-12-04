import Foundation
import KsApi

public func serverFeaturePledgedProjectsOverviewIsEnabled() -> Bool {
  return ServerFeature.pledgeProjectsOverviewIos_2024.isEnabled()
}

extension ServerFeature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    environment.currentUserServerFeatures?.contains(self) ?? false
  }
}

extension Set: EncodableType where Element == ServerFeature {
  public func encode() -> [String: Any] {
    ["features": Array(self).map { $0.rawValue }]
  }
}
