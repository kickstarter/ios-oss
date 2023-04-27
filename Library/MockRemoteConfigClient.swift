import FirebaseRemoteConfig
import Foundation

public enum MockRemoteConfigError: Error {
  case generic

  var localizedDescription: String {
    return "Mock Remote Config Error"
  }
}

private class MockRemoteConfigValue: RemoteConfigValue {
  var bool = false
}

public class MockRemoteConfigClient: RemoteConfigClientType {
  public var features: [String: Bool]
  public var error: MockRemoteConfigError?

  public init() {
    self.features = [:]
  }

  public func configValue(forKey key: String?) -> RemoteConfigValue {
    let value = MockRemoteConfigValue()
    value.bool = self.features[key ?? ""] == true

    return value
  }

  public func activate(completion _: ((Bool, Error?) -> Void)?) {}

  public func fetch(completionHandler _: ((RemoteConfigFetchStatus, Error?) -> Void)?) {}

  public func setDefaults(_: [String: NSObject]?) {}
}
