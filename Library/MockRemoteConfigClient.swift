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

  public func activate(completion _: ((Bool, Error?) -> Void)?) {}

  public func configValue(forKey key: String?) -> RemoteConfigValue {
    let value = MockRemoteConfigValue()
    value.bool = self.features[key ?? ""] == true

    return value
  }

  public func fetch(completionHandler _: ((RemoteConfigFetchStatus, Error?) -> Void)?) {}

  public func setDefaults(_: [String: NSObject]?) {}

  public func addOnConfigUpdateListener(remoteConfigUpdateCompletion _: @escaping (
    RemoteConfigUpdate?,
    Error?
  ) -> Void) -> ConfigUpdateListenerRegistration {
    return ConfigUpdateListenerRegistration()
  }

  public func isFeatureEnabled(featureKey: RemoteConfigFeature) -> Bool {
    return self.features[featureKey.rawValue] == true
  }
}
