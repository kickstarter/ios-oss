/// An experiment to make pages in the pledge flow load much faster.
public struct SpeedyCheckoutExperiment: StatsigExperimentProtocol {
  typealias ExperimentParameters = SpeedyCheckoutExperiment.Parameters

  public enum Parameters: String, CaseIterable {
    case speedy_checkout_enabled
  }

  public var name: StatsigExperimentName {
    return .speedy_checkout_experiment
  }

  public var layer: StatsigExperimentLayer? {
    return nil
  }

  public init() {}
}
