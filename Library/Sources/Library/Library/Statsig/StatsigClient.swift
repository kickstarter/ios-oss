import Statsig

public final class StatsigClient: StatsigClientType {
  private let sdkKey: String

  public init(sdkKey: String) {
    self.sdkKey = sdkKey
  }

  /// Initializes the SDK with the given user. Call once on app launch.
  public func initialize(userID: String?) {
    Statsig.initialize(sdkKey: self.sdkKey, user: StatsigUser(userID: userID)) { error in
      debugPrint("Statsig initializer error: \(error?.localizedDescription)")
    }
  }

  /// Returns `true` if the named gate is enabled for the current user.
  public func checkGate(for feature: StatsigFeature) -> Bool {
    Statsig.checkGate(feature.rawValue)
  }
}
