/// This is an A/A experiment to test that our A/B testing infrastructure works correctly.
/// Nothing is actually changed by this experiment.
public struct NullExperiment: StatsigExperimentProtocol {
  typealias ExperimentParameters = NullExperiment.Parameters

  let isLoggedIn: Bool

  public init(isLoggedIn: Bool) {
    self.isLoggedIn = isLoggedIn
  }

  public enum Parameters: String, CaseIterable {
    case test_parameter
  }

  public var name: StatsigExperimentName {
    return self.isLoggedIn ? .logged_in_aa_experiment : .logged_out_aa_experiment
  }
}
