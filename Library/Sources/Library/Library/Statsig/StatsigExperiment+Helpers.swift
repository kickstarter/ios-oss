import Experimentation

public extension StatsigExperimentProtocol {
  func boolValue(forKey key: Parameters) -> Bool? {
    // TODO(CHECK-109): Add a manual override stored in user preferences, like we use for features.
    // Or maybe just use Statsig's override code.
    // This will let us build out a debug UI to manually override these.
    return AppEnvironment.current.statsigClient?
      .boolValue(forKey: key, inExperiment: self)
  }
}

public extension StatsigExperimentName {
  var experimentFromName: any StatsigExperimentProtocol {
    switch self {
    case .ios_test_experiment:
      return iOSTestExperiment()
    case .fullscreen_checkout_experience_experiment:
      return FullScreenCheckoutExperiment()
    }
  }
}

extension StatsigClientType {
  // TODO(CHECK-109): It would be nice to add an interface to show all experiments, and allow us to manually override them.
  // This is a stub/reminder for that.
  public func allExperiments() -> [any StatsigExperimentProtocol] {
    return StatsigExperimentName.allCases.map {
      $0.experimentFromName
    }
  }
}
