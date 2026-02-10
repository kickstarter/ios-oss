import GraphAPI
import Prelude
import ReactiveSwift

public struct ProjectPageFetcher {
  let apiService: ServiceType

  public init(withService apiService: any ServiceType) {
    self.apiService = apiService
  }

  public func fetchProjectPage(
    projectParam param: Param,
    configCurrency: String?
  ) -> SignalProducer<Project, ErrorEnvelope> {
    let projectAndBackingIdProducer = self.apiService.fetchProject(
      projectParam: param,
      configCurrency: configCurrency
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
            let updatedProjectWithBacking = projectWithBacking.project
              |> Project.lens.personalization.backing .~ projectWithBacking.backing
              |> Project.lens.personalization.isBacking .~ true
              |> Project.lens.extendedProjectProperties .~ projectWithBacking.project
              .extendedProjectProperties
              // INFO: Seems like in the `fetchBacking` call we nil out the chosen currency set by `fetchProject` b/c the query for backing doesn't have `me { chosenCurrency }`, so its' being included here.
              |> Project.lens.stats.userCurrency .~ projectPamphletData.project.stats.userCurrency

            return self.fetchProjectRewards(project: updatedProjectWithBacking)
          }

        return projectWithBackingAndRewards
      }

    return projectAndBackingProducer
  }

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
          |> Project.lens.extendedProjectProperties .~ project.extendedProjectProperties

        return SignalProducer(value: projectWithBackingAndRewards)
      }
  }
}
