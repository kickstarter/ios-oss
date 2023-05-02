import FirebaseRemoteConfig
import Foundation

private class MockRemoteConfigValue: RemoteConfigValue {
  var bool = false
}

public class MockRemoteConfigClient: RemoteConfigClientType {
  public var features: [String: Bool]

  public init() {
    self.features = [:]
  }

  public func activate() async throws -> Bool {
    return true
  }

  public func configValue(forKey key: String?) -> RemoteConfigValue {
    let value = MockRemoteConfigValue()
    value.bool = self.features[key ?? ""] == true

    return value
  }

  public func fetchAndActivate(completionHandler _: ((RemoteConfigFetchAndActivateStatus, Error?)
      -> Void)?) {}

  public func setDefaults(_: [String: NSObject]?) {}

//  public func addOnConfigUpdateListener(remoteConfigUpdateCompletion listener: @escaping (RemoteConfigUpdate?, Error?) -> Void) -> ConfigUpdateListenerRegistration {}

  public func isFeatureEnabled(featureKey: RemoteConfigFeature) -> Bool {
    return self.features[featureKey.rawValue] == true
  }
}
