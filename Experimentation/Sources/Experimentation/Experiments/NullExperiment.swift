public enum NullExperimentParameters: String, CaseIterable {
  case test_parameter
}

/// This is an A/A experiment to test that our A/B testing infrastructure works correctly.
/// Nothing is actually changed by this experiment.
public struct NullExperimentWithUserID: StatsigExperimentProtocol {
  public typealias Parameters = NullExperimentParameters

  public init() {}

  public var name: StatsigExperimentName {
    return .logged_in_aa_experiment
  }

  public var layer: StatsigExperimentLayer? {
    return nil
  }
}

/// This is an A/A experiment to test that our A/B testing infrastructure works correctly.
/// Nothing is actually changed by this experiment.
public struct NullExperimentWithAnonymousID: StatsigExperimentProtocol {
  public typealias Parameters = NullExperimentParameters

  public init() {}

  public var name: StatsigExperimentName {
    return .logged_out_aa_experiment
  }

  public var layer: StatsigExperimentLayer? {
    return nil
  }
}
