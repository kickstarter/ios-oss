/// A test experiment for Statsig, defined as `ios_test_experiment` in the console.
public struct iOSTestExperiment: StatsigExperimentProtocol {
  typealias ExperimentParameters = iOSTestExperiment.Parameters

  public enum Parameters: String, CaseIterable {
    case experiment_parameter_one
    case experiment_parameter_two
  }

  public var name: StatsigExperimentName {
    return .ios_test_experiment
  }
}
