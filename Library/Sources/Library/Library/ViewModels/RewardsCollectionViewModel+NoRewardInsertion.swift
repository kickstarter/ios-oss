import KsApi

/// Inserts 'No Reward' before all the project rewards
struct NoRewardFirst: NoRewardInserter {
  func insert(noReward: Reward, intoRewards rewards: [Reward]) -> [Reward] {
    return [noReward] + rewards
  }
}

/// Inserts 'No Reward' after the last reward that is available, using `rewardsCarouselCanNavigateToReward` to check availability.
struct NoRewardAfterLastAvailableReward: NoRewardInserter {
  let shippingLocation: Location?
  let project: Project

  public init(shippingLocation: Location?, project: Project) {
    self.shippingLocation = shippingLocation
    self.project = project
  }

  private func indexOfFirstUnavailableReward(_ rewards: [Reward]) -> Int? {
    return rewards.firstIndex(where: { reward in
      !rewardsCarouselCanNavigateToReward(
        reward,
        in: self.project,
        selectedShippingLocation: self.shippingLocation
      )
    })
  }

  func insert(noReward: Reward, intoRewards rewards: [Reward]) -> [Reward] {
    var newRewards = rewards
    if let firstUnavailable = self.indexOfFirstUnavailableReward(rewards) {
      newRewards.insert(noReward, at: firstUnavailable)
    } else {
      newRewards.append(noReward)
    }
    return newRewards
  }
}
