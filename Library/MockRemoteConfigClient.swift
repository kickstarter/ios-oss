import FirebaseRemoteConfig
import Foundation

private class MockRemoteConfigValue: RemoteConfigValue {
  var bool = false

  override var boolValue: Bool { self.bool }
}

public class MockRemoteConfigClient: RemoteConfigClientType {
  public func fetchAndActivate(completionHandler _: (
    (RemoteConfigFetchAndActivateStatus, Error?)
      -> Void
  )?) {}

  public var features: [String: Bool]

  public init() {
    self.features = [:]
  }

  public func activate(completion _: ((Bool, Error?) -> Void)?) {}

  public func configValue(forKey key: String?) -> RemoteConfigValue {
    let value = MockRemoteConfigValue()

    guard let keyValue = key else {
      return value
    }

    value.bool = self.features[keyValue] == true

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
}
