import Experimentation
import Foundation

public final class MockStatsigWrapper: StatsigClientType {
  public var features: [StatsigFeature: Bool] = [:]

  // Set experiments by calling overrideExperiment(_,withMock:)
  // This array is more like [String: MockExperiment<some StatsigExperimentProtocol>],
  // but the type system doesn't like undefined generics in a container - so we get AnyObject.
  private var experiments: [String: AnyObject] = [:]

  public init() {}

  public func initialize(withUser _: StatsigClientUser) {}

  public func reload(withUser _: StatsigClientUser) {}

  public func showDebugger() {}

  public func checkGate(for feature: StatsigFeature) -> Bool? {
    self.features[feature]
  }

  /// Set mock values for an experiment using MockStatsigExperiment.
  public func overrideExperiment<T: StatsigExperimentProtocol>(
    _ experiment: T,
    withMock mock: MockExperiment<T>
  ) {
    self.experiments[experiment.name.rawValue] = mock as AnyObject
  }

  public func boolValue<T: StatsigExperimentProtocol>(
    forKey key: T.Parameters,
    inExperiment experiment: T
  ) -> Bool? {
    guard let mockExperiment = self.experiments[experiment.name.rawValue] as? MockExperiment<T>
    else {
      return nil
    }

    return mockExperiment.boolValue(forKey: key)
  }
}

/// Allows us to mock a Statsig experiment for testing purposes.
///
/// Example usage:
/// ```swift
/// MockExperiment<iOSTestExperiment> = MockExperiment([
///   .test_parameter_one: true
/// ])
/// ```
public struct MockExperiment<T> where T: StatsigExperimentProtocol {
  private let parameters: [T.Parameters: Bool]

  public init(_ parameters: [T.Parameters: Bool]) {
    self.parameters = parameters
  }

  func boolValue(forKey key: T.Parameters) -> Bool? {
    return self.parameters[key]
  }
}
