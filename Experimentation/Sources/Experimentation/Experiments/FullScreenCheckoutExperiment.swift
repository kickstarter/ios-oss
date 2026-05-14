/// An experiment with how we present screens in checkout.
public struct FullScreenCheckoutExperiment: StatsigExperimentProtocol {
  typealias ExperimentParameters = FullScreenCheckoutExperiment.Parameters

  public enum Parameters: String, CaseIterable {
    case fullscreen_project_page
    case push_spc
  }

  public var name: StatsigExperimentName {
    return .fullscreen_checkout_experience_experiment
  }

  public init() {}
}
