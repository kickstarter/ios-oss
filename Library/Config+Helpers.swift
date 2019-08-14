import Foundation
import KsApi

extension Experiment.Name {
  public func isEnabled(in environment: Environment = AppEnvironment.current) -> Bool {
    guard let experiments = environment.config?.abExperiments else { return false }

    if let variant = experiments[self.rawValue] {
      return Experiment.Variant(rawValue: variant) == .experimental
    }

    return false
  }
}
