internal import Statsig

public final class StatsigClient: StatsigClientType {
  private let sdkKey: String

  public init(sdkKey: String) {
    self.sdkKey = sdkKey
  }

  public func showDebugger() {
    Statsig.openDebugView()
  }

  public func reload(withUserID userID: String?) {
    Statsig.updateUserWithResult(StatsigUser(userID: userID)) { error in
      if let error {
        debugPrint("Statsig reload error: \(error.localizedDescription)")
      } else {
        debugPrint("Successfully reloaded Statsig")
      }
    }
  }

  /// Initializes the SDK with the given user. Call once on app launch.
  public func initialize(userID: String?) {
    Statsig.initialize(sdkKey: self.sdkKey, user: StatsigUser(userID: userID)) { error in
      if let error {
        debugPrint("Statsig initializer error: \(error.localizedDescription)")
      } else {
        debugPrint("Successfully initialized Statsig")
      }
    }
  }

  /// Returns `true` if the named gate is enabled for the current user.
  public func checkGate(for feature: StatsigFeature) -> Bool {
    Statsig.checkGate(feature.rawValue)
  }

  public func boolValue<T: StatsigExperimentProtocol>(
    forKey key: T.Parameters,
    inExperiment experiment: T
  ) -> Bool? {
    return Statsig
      .getExperiment(experiment.name.rawValue)
      .getValue(forKey: key.rawValue)
  }
}
