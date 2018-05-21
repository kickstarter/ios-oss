import Foundation
import KsApi

extension Experiment.Name {
  public func isEnabled(in environment: Environment) -> Bool {
    guard let experiments = AppEnvironment.current.config?.abExperiments else { return false }

    if let variant = experiments[self.rawValue] {
      return Experiment.Variant(rawValue: variant) == .experimental
    }

    return false
  }
}
