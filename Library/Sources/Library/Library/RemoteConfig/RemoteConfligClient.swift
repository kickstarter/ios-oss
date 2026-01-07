import FirebaseRemoteConfig

public class RemoteConfigClient: RemoteConfigClientType {
  public func fetchAndActivate(completionHandler: ((RemoteConfigFetchAndActivateStatus, Error?) -> Void)?) {
    self.sharedClient.fetchAndActivate(completionHandler: completionHandler)
  }

  private var sharedClient: RemoteConfig

  public init(with client: RemoteConfig) {
    self.sharedClient = client
  }

  public func activate(completion: ((Bool, Error?) -> Void)?) {
    self.sharedClient.activate(completion: completion)
  }

  public func fetch(completionHandler: ((RemoteConfigFetchStatus, Error?) -> Void)?) {
    self.sharedClient.fetch(completionHandler: completionHandler)
  }

  public func setDefaults(_ defaults: [String: NSObject]?) {
    self.sharedClient.setDefaults(defaults)
  }

  public func addOnConfigUpdateListener(remoteConfigUpdateCompletion listener: @escaping (
    RemoteConfigUpdate?,
    Error?
  ) -> Void) -> ConfigUpdateListenerRegistration {
    self.sharedClient.addOnConfigUpdateListener(remoteConfigUpdateCompletion: listener)
  }

  public func configValue(forKey key: String?) -> RemoteConfigValue {
    self.sharedClient.configValue(forKey: key)
  }
}
