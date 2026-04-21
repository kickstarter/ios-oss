import Foundation

/// Abstracts the Statsig SDK so the rest of the app never imports Statsig directly.
public protocol StatsigClientType: AnyObject {
  /// Initializes Statsig and fetches gates/configs for the given user.
  func initialize(userID: String?)

  /// Returns whether a feature gate is enabled for the current user.
  func checkGate(for feature: StatsigFeature) -> Bool

  /// Returns a boolean value from an experiment.
  /// May return `nil` if the experiment or key are invalid.
  func boolValue<T: StatsigExperimentProtocol>(forKey key: T.Parameters, inExperiment experiment: T) -> Bool?
}

extension StatsigClientType {
  /* Returns all features the app knows about */

  public func allFeatures() -> [StatsigFeature] {
    return StatsigFeature.allCases
  }

  public func isFeatureEnabled(featureKey key: StatsigFeature) -> Bool {
    AppEnvironment.current.statsigClient?.checkGate(for: key) == true
  }
}

extension StatsigClientType {
  // TODO(CHECK-109): It would be nice to add an interface to show all experiments, and allow us to manually override them.
  // This is a stub/reminder for that.
  public func allExperiments() -> [any StatsigExperimentProtocol] {
    return StatsigExperimentName.allCases.map {
      $0.experimentFromName
    }
  }
}
