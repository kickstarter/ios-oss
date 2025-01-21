import Foundation
import KsApi

extension ServerFeature {
  private func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    environment.currentUserServerFeatures?.contains(self) ?? false
  }
}

extension Set: KsApi.EncodableType where Element == ServerFeature {
  public func encode() -> [String: Any] {
    ["features": Array(self).map { $0.rawValue }]
  }
}
