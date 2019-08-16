import Foundation
import KsApi

public func nativeCheckoutExperimentIsEnabled() -> Bool {
  return Experiment.Name.nativeCheckoutV1.isEnabled()
}

extension Experiment.Name {
  fileprivate func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let experiments = environment.config?.abExperiments else { return false }

    if let variant = experiments[self.rawValue] {
      return Experiment.Variant(rawValue: variant) == .experimental
    }

    return false
  }
}
