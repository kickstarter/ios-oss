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

/// A thin wrapper around the Statsig class `StatsigClient`.
public final class StatsigWrapper: StatsigClientType {
  private let client: StatsigClient

  public convenience init(sdkKey: StatsigClientSDKKey, userID: String?) {
    let key: String
    let tier: StatsigEnvironment.EnvironmentTier

    switch sdkKey {
    case let .production(prodKey):
      key = prodKey
      tier = .Production
    case let .staging(stagingKey):
      key = stagingKey
      tier = .Staging
    }

    let client = StatsigClient(
      sdkKey: key,
      user: StatsigUser(userID: userID),
      options: StatsigOptions(environment: StatsigEnvironment(tier: tier))
    ) { error in
      if let error {
        debugPrint("Statsig reload error: \(error.localizedDescription)")
      } else {
        NotificationCenter.default.post(name: StatsigLoadedNotification, object: nil)
        debugPrint("Successfully reloaded Statsig")
      }
    }

    self.init(client: client)
  }

  init(client: StatsigClient) {
    self.client = client
  }

  public func showDebugger() {
    self.client.openDebugView()
  }

  public func reload(withUserID userID: String?) {
    self.client.updateUserWithResult(StatsigUser(userID: userID)) { error in
      if let error {
        debugPrint("Statsig reload error: \(error.localizedDescription)")
      } else {
        NotificationCenter.default.post(name: StatsigLoadedNotification, object: nil)
        debugPrint("Successfully reloaded Statsig")
      }
    }
  }

  public func checkGate(for feature: StatsigFeature) -> Bool? {
    guard self.client.isInitialized() else {
      return nil
    }

    return self.client.checkGate(feature.rawValue)
  }

  public func boolValue<T: StatsigExperimentProtocol>(
    forKey key: T.Parameters,
    inExperiment experiment: T
  ) -> Bool? {
    guard self.client.isInitialized() else {
      return nil
    }

    return self.client
      .getExperiment(experiment.name.rawValue)
      .getValue(forKey: key.rawValue)
  }
}
