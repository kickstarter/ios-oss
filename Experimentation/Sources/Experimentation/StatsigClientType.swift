import Foundation

/// Abstracts the Statsig user type away from the SDK.
public struct StatsigClientUser {
  let ksrUserId: Int?
  let segmentAnonymousId: String?

  public init(ksrUserId: Int?, segmentAnonymousId: String?) {
    self.ksrUserId = ksrUserId
    self.segmentAnonymousId = segmentAnonymousId
  }
}

/// Abstracts the Statsig SDK so the rest of the app never imports Statsig directly.
public protocol StatsigClientType: AnyObject {
  /// Reloads Statsig with values the for the given user.
  /// Switches the user and pulls in their current values.
  func reload(withUser: StatsigClientUser)

  /// Shows the Statsig debugger.
  func showDebugger()

  /// Returns whether a feature gate is enabled for the current user.
  /// May return `nil` if `Statsig` has not completed initialization.
  func checkGate(for feature: StatsigFeature) -> Bool?

  /// Returns a boolean value from an experiment.
  /// May return `nil` if the experiment or key are invalid.
  func boolValue<T: StatsigExperimentProtocol>(forKey key: T.Parameters, inExperiment experiment: T) -> Bool?

  // Statsig supports Bool, Int, String and even Object parameters for experiments.
  // When and if we need them, we can expand this implementation to support more types.

  // func intValue<T: StatsigExperimentProtocol>(forKey key: T.Parameters, inExperiment experiment: T) -> Int?
  // func stringValue<T: StatsigExperimentProtocol>(forKey key: T.Parameters, inExperiment experiment: T) -> String?
}
