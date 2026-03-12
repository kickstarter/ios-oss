import Foundation

public final class MockStatsigClient: StatsigClientType {
  public var features: [String: Bool] = [:]

  public var initializedUserIDs: [String] = []
  public var updatedUserIDs: [String] = []

  public init() {}

  public func initialize(userID: String?) {
    if let userID {
      self.initializedUserIDs.append(userID)
    }
  }

  public func updateUser(userID: String) {
    self.updatedUserIDs.append(userID)
  }

  public func checkGate(for feature: StatsigFeature) -> Bool {
    self.features[feature.rawValue] ?? false
  }
}
