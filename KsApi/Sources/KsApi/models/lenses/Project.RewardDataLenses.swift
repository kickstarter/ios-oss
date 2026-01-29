import Prelude

extension Project.RewardData {
  public enum lens {
    public static let addOns = Lens<Project.RewardData, [Reward]?>(
      view: { $0.addOns },
      set: { Project.RewardData(addOns: $0, rewards: $1.rewards) }
    )

    public static let rewards = Lens<Project.RewardData, [Reward]>(
      view: { $0.rewards },
      set: { Project.RewardData(addOns: $1.addOns, rewards: $0) }
    )
  }
}
