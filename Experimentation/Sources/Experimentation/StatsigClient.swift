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

  public convenience init(sdkKey: StatsigClientSDKKey, user: StatsigClientUser) {
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
      user: StatsigUser.from(user),
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

  public func reload(withUser user: StatsigClientUser) {
    let user = StatsigUser.from(user)
    self.client.updateUserWithResult(user) { error in
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

private extension StatsigUser {
  /// Create a `StatsigUser` (Statsig's model object) from a `StatsigClientUser` (our model object)
  static func from(_ clientUser: StatsigClientUser) -> StatsigUser {
    let ksrStringId = clientUser.ksrUserId != nil ? String(clientUser.ksrUserId!) : nil

    if let segmentId = clientUser.segmentAnonymousId {
      return StatsigUser(userID: ksrStringId, customIDs: ["segmentAnonymousId": segmentId])
    } else {
      return StatsigUser(userID: ksrStringId)
    }
  }
}
