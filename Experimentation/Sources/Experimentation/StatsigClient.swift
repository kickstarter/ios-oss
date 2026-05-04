internal import Statsig
import Foundation

public let StatsigLoadedNotification = NSNotification.Name("StatsigClientDataReloaded")

/// SDK keys in Statsig can be associated with "environment tiers" - development, staging or production.
/// The Statsig client needs to be initialized with the same tier that the SDK key supports.
///
/// See Statsig's documentation: https://docs.statsig.com/guides/using-environments
public enum StatsigClientSDKKey {
  /// An SDK key which will be sent to the Staging tier of Statsig.
  case staging(String)
  /// An SDK key which will be sent to the Production tier of Statsig
  case production(String)
}

public final class StatsigClient: StatsigClientType {
  private let sdkKey: StatsigClientSDKKey

  public init(sdkKey: StatsigClientSDKKey) {
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
        NotificationCenter.default.post(name: StatsigLoadedNotification, object: nil)
        debugPrint("Successfully reloaded Statsig")
      }
    }
  }

  /// Initializes the SDK with the given user. Call once on app launch.
  public func initialize(userID: String?) {
    let key: String
    let tier: StatsigEnvironment.EnvironmentTier

    switch self.sdkKey {
    case let .production(prodKey):
      key = prodKey
      tier = .Production
    case let .staging(stagingKey):
      key = stagingKey
      tier = .Staging
    }

    Statsig.initialize(
      sdkKey: key,
      user: StatsigUser(userID: userID),
      options: StatsigOptions(environment: StatsigEnvironment(tier: tier))
    ) { error in
      if let error {
        debugPrint("Statsig initializer error: \(error.localizedDescription)")
      } else {
        NotificationCenter.default.post(name: StatsigLoadedNotification, object: nil)
        debugPrint("Successfully initialized Statsig")
      }
    }
  }

  /// Returns `true` if the named gate is enabled for the current user.
  public func checkGate(for feature: StatsigFeature) -> Bool? {
    guard Statsig.isInitialized() else {
      return nil
    }

    return Statsig.checkGate(feature.rawValue)
  }

  public func boolValue<T: StatsigExperimentProtocol>(
    forKey key: T.Parameters,
    inExperiment experiment: T
  ) -> Bool? {
    guard Statsig.isInitialized() else {
      return nil
    }

    return Statsig
      .getExperiment(experiment.name.rawValue)
      .getValue(forKey: key.rawValue)
  }
}
