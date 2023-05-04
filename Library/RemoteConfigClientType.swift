import FirebaseRemoteConfig
import Foundation

public protocol RemoteConfigClientType: AnyObject {
  func activate(completion: ((Bool, Error?) -> Void)?)
  func configValue(forKey key: String?) -> RemoteConfigValue
  func fetch(completionHandler: ((RemoteConfigFetchStatus, Error?) -> Void)?)
  func setDefaults(_ defaults: [String: NSObject]?)
  func addOnConfigUpdateListener(remoteConfigUpdateCompletion listener: @escaping (
    RemoteConfigUpdate?,
    Error?
  ) -> Void) -> ConfigUpdateListenerRegistration
//  func isFeatureEnabled(featureKey: RemoteConfigFeature) -> Bool
}

extension RemoteConfigClientType {
  /* Returns all features the app knows about */

  public func allFeatures() -> [RemoteConfigFeature] {
    return RemoteConfigFeature.allCases
  }

  public func isFeatureEnabled(featureKey: RemoteConfigFeature) -> Bool {
    RemoteConfig.remoteConfig()[featureKey.rawValue].boolValue
  }
}
