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
