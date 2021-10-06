import Apollo
import Prelude
import ReactiveSwift

extension Project {
  static func projectRewardsProducer(
    from data: GraphAPI.FetchProjectRewardsByIdQuery.Data
  ) -> SignalProducer<[Reward], ErrorEnvelope> {
    let projectRewards = Project.projectRewards(from: data)

    return SignalProducer(value: projectRewards)
  }

  static func projectRewards(from data: GraphAPI.FetchProjectRewardsByIdQuery.Data) -> [Reward] {
    let projectRewards = data.project?.rewards?.nodes?
      .compactMap { $0?.fragments.rewardFragment }
      .compactMap { Reward.reward(from: $0) } ?? []

    return projectRewards
  }
}
