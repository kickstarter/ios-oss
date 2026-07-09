/// An experiment to make the `Back this Project` button on the Project page load much faster.
public struct InstantPledgeButtonExperiment: StatsigExperimentProtocol {
  typealias ExperimentParameters = InstantPledgeButtonExperiment.Parameters

  public enum Parameters: String, CaseIterable {
    case instant_pledge_enabled
  }

  public var name: StatsigExperimentName {
    return .instant_pledge_button_experiment
  }

  public var layer: StatsigExperimentLayer? {
    return nil
  }

  public init() {}
}
