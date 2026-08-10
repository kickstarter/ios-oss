import Prelude
import ReactiveSwift

public struct ProjectPageFetcher {
  let apiService: ServiceType

  public init(withService apiService: any ServiceType) {
    self.apiService = apiService
  }

  public func fetchProjectPage(
    projectParam param: Param
  ) -> SignalProducer<Project, ErrorEnvelope> {
    let projectAndBackingIdProducer = self.apiService.fetchProject(
      projectParam: param
    )

    let projectAndBackingProducer = projectAndBackingIdProducer
      .switchMap { projectPamphletData -> SignalProducer<Project, ErrorEnvelope> in
        guard let backingId = projectPamphletData.backingId else {
          return self.fetchProjectRewards(project: projectPamphletData.project)
        }

        let projectWithBackingAndRewards = self
          .apiService
          .fetchBacking(id: backingId)
          .switchMap { projectWithBacking -> SignalProducer<Project, ErrorEnvelope> in
            let fullProject = projectPamphletData.project

            let updatedProjectWithBacking = fullProject
              |> Project.lens.personalization.backing .~ projectWithBacking.backing
              |> Project.lens.personalization.isBacking .~ true

            return self.fetchProjectRewards(project: updatedProjectWithBacking)
          }

        return projectWithBackingAndRewards
      }

    return projectAndBackingProducer
  }

  // TODO: Clean up rewards fetch.
  // We now fetch the rewards directly in the RewardsCollectionViewController.
  // However, other parts of the pledge flow use the rewards attached to the Project to handle other logic -
  // like checking to see if the project has rewards that require shipping, or picking the correct shipping rule.
  // If we can clean up and decouple that behavior from the rest of the pledge flow, we can eliminate this fetch,
  // making the project page load substantially faster.
  private func fetchProjectRewards(project: Project) -> SignalProducer<Project, ErrorEnvelope> {
    return self.apiService
      .fetchProjectRewards(projectId: project.id)
      .switchMap { projectRewards -> SignalProducer<Project, ErrorEnvelope> in

        var allRewards = projectRewards

        if let noRewardReward = project.rewardData.rewards.first {
          allRewards.insert(noRewardReward, at: 0)
        }

        let projectWithBackingAndRewards = project
          |> Project.lens.rewardData.rewards .~ allRewards

        return SignalProducer(value: projectWithBackingAndRewards)
      }
  }
}
