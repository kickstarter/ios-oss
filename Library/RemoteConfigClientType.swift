import FirebaseRemoteConfig
import Foundation

public enum RemoteConfigClientTypeError: Error {
  case activate(_: Error?)
  case fetch(_: Error?)

  var localizedDescription: String {
    switch self {
    case let .activate(error):
      return "Error activating Remote Config \(error?.localizedDescription ?? "")"
    case let .fetch(error):
      return "Error fetching Remote Config \(error?.localizedDescription ?? "")"
    }
  }
}

public protocol RemoteConfigClientType: AnyObject {
  func activate(completion: ((Bool, Error?) -> Void)?)
  func configValue(forKey key: String?) -> RemoteConfigValue
  func fetch(completionHandler: ((RemoteConfigFetchStatus, Error?) -> Void)?)
  func setDefaults(_ defaults: [String: NSObject]?)
}

extension RemoteConfigClientType {
  /* Returns all features the app knows about */

  public func allFeatures() -> [RemoteConfigFeature] {
    return RemoteConfigFeature.allCases
  }

  public func bool(forKey key: RemoteConfigFeature) -> Bool {
    RemoteConfig.remoteConfig()[key.rawValue].boolValue
  }
}
