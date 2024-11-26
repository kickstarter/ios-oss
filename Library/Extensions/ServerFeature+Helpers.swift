import Foundation
import KsApi

public func serverFeaturePledgedProjectsOverviewIsEnabled() -> Bool {
  return ServerFeature.pledgeProjectsOverview_2024.isEnabled()
}

extension ServerFeature {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    environment.currentUserFeatures?.contains(self) ?? false
  }
}

extension Set: EncodableType where Element == ServerFeature {
  public func encode() -> [String : Any] {
    ["features": Array(self).map({ $0.rawValue })]
  }
}
