/// An experiment to move the 'Pledge without a reward' (aka No Reward) card in the Rewards carousel.
public struct MoveNoRewardOptionExperiment: StatsigExperimentProtocol {
  typealias ExperimentParameters = MoveNoRewardOptionExperiment.Parameters

  public enum Parameters: String, CaseIterable {
    case show_no_reward_after_available_rewards
  }

  public var name: StatsigExperimentName {
    return .move_no_reward_option_ios
  }

  public var layer: StatsigExperimentLayer? {
    return .ios_checkout
  }

  public init() {}
}
