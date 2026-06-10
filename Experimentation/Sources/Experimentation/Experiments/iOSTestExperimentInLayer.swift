/// A test experiment for Statsig, in a layer, defined as `ios_test_experiment_in_layer` in the console.
public struct iOSTestExperimentInLayer: StatsigExperimentProtocol {
  typealias ExperimentParameters = iOSTestExperimentInLayer.Parameters

  public enum Parameters: String, CaseIterable {
    case test_parameter
  }

  public var name: StatsigExperimentName {
    return .ios_test_experiment_in_layer
  }

  public var layer: StatsigExperimentLayer? {
    return .ios_test_layer
  }

  public init() {}
}
