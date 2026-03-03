import GraphAPI
import Prelude

extension Reward {
  /**
   This is a consequence of the no-reward reward being returned on v1 but not in GQL. We have to create and insert the reward ourself to get the same behavior.
   */
  public static func noRewardReward(from fragment: GraphAPI.NoRewardRewardFragment) -> Reward {
    let projectMinimumPledgeAmount: Int = fragment.minPledge
    let currentUsersCurrencyFXRate: Double = fragment.fxRate

    let convertedMinimumAmount = currentUsersCurrencyFXRate * Double(projectMinimumPledgeAmount)

    let emptyReward = Reward.noReward(
      withMinimum: Double(projectMinimumPledgeAmount),
      convertedMinimum: convertedMinimumAmount
    )

    return emptyReward
  }
}
