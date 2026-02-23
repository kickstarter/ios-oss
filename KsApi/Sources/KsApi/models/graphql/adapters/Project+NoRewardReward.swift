import GraphAPI
import Prelude

extension Reward {
  public static func noRewardReward(from fragment: GraphAPI.NoRewardRewardFragment?) -> Reward {
    let projectMinimumPledgeAmount: Int = fragment?.minPledge ?? 1
    let currentUsersCurrencyFXRate: Double = fragment?.fxRate ?? 1.0

    let convertedMinimumAmount = currentUsersCurrencyFXRate * Double(projectMinimumPledgeAmount)

    let emptyReward = Reward.noReward
      |> Reward.lens.minimum .~ Double(projectMinimumPledgeAmount)
      |> Reward.lens.convertedMinimum .~ convertedMinimumAmount

    return emptyReward
  }
}
