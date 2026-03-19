import Foundation

public final class MockStatsigClient: StatsigClientType {
  public var features: [String: Bool] = [:]

  public init() {}

  public func initialize(userID _: String?) {}

  public func checkGate(for feature: StatsigFeature) -> Bool {
    self.features[feature.rawValue] ?? false
  }
}
