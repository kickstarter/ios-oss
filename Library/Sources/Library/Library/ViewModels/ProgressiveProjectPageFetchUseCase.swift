import Experimentation
import KsApi
import ReactiveSwift

/// Progressive fetching logic for ProjectPageViewModel.
public struct ProjectPageViewModel_ProgressiveFetchUseCase {
  private let errors: Signal<ErrorEnvelope, Never>
  private let partialFetch: Signal<(Project, RefTag?), Never>
  private let fullFetch: Signal<(Project, RefTag?), Never>
  public let isLoading: Signal<Bool, Never>

  public enum ProgressiveFetchType {
    case partial
    case full
  }

  // inputs
  init(
    configData: Signal<(Param, RefTag?, String?), Never>,
    shouldRefreshProject: Signal<Void, Never>
  ) {
    let isLoading = MutableProperty<Bool>(false)
    self.isLoading = isLoading.signal

    let experiment = InstantPledgeButtonExperiment()
    guard experiment.boolValue(forKey: .instant_pledge_enabled) == true else {
      let fetch = configData
        .takeWhen(shouldRefreshProject)
        .switchMap { projectOrParam, refTag, token in
          RewardsUseCase.addUserToSecretRewardGroupIfNeeded(
            project: projectOrParam.param,
            secretRewardToken: token
          ).switchMap { _ in
            fetchFullProjectPage(
              param: projectOrParam
            )
          }
          .on(
            starting: { isLoading.value = true },
            terminated: { isLoading.value = false }
          )
          .map { project in
            (project, refTag)
          }
          .materialize()
        }

      self.fullFetch = fetch.values()
      self.errors = fetch.errors()

      // This is the original code, so it has no partial fetching.
      // Return the full results for any calls to partial results.
      self.partialFetch = self.fullFetch
      return
    }

    let firstFetch = configData
      .takeWhen(shouldRefreshProject)
      .switchMap { param, refTag, token in
        RewardsUseCase.addUserToSecretRewardGroupIfNeeded(
          project: param,
          secretRewardToken: token
        ).switchMap { _ in
          progressiveFetchInitial(param: param)
        }
        .on(
          starting: { isLoading.value = true }
        )
        .map { project in
          (project, refTag)
        }
        .materialize()
      }

    let secondFetch = configData
      .takeWhen(shouldRefreshProject)
      .switchMap { param, _, _ in
        // TODO: just fetch the extra project props.
        progressiveFetchSecondary(param: param)
          .materialize()
      }

    self.partialFetch = firstFetch.values()

    self.fullFetch = Signal.zip(
      self.partialFetch,
      secondFetch.values()
    ).map { projectAndRefTag, extraProperties in
      // TODO: actually combine this stuff
      let (initialProject, refTag) = projectAndRefTag
      let updatedProject = extraProperties.addExtraProperties(toProject: initialProject)
      return (updatedProject, refTag)
    }.on(completed: {
      isLoading.value = false
    })

    self.errors = Signal.merge(
      firstFetch.errors(),
      secondFetch.errors()
    )
  }

  // outputs
  func projectAndRefTag(_ type: ProgressiveFetchType) -> Signal<(Project, RefTag?), Never> {
    switch type {
    case .partial:
      return self.partialFetch
    case .full:
      return self.fullFetch
    }
  }

  func project(_ type: ProgressiveFetchType) -> Signal<Project, Never> {
    return self.projectAndRefTag(type).map { $0.0 }
  }

  func error(_: ProgressiveFetchType) -> Signal<ErrorEnvelope, Never> {
    return self.errors
  }
}

private func fetchFullProjectPage(
  param: Param
) -> SignalProducer<Project, ErrorEnvelope> {
  let fetcher = ProjectPageFetcher(withService: AppEnvironment.current.apiService)

  let producer = fetcher.fetchProjectPage(
    projectParam: param
  )
  .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)

  return producer
}

private func progressiveFetchInitial(
  param: Param
) -> SignalProducer<Project, ErrorEnvelope> {
  return AppEnvironment.current.apiService.fastFetchProjectPage_Checkout(
    projectParam: param
  )
  .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
}

private func progressiveFetchSecondary(
  param: Param
) -> SignalProducer<ProjectPageExtraProperties, ErrorEnvelope> {
  return AppEnvironment.current.apiService.fastFetchProjectPage_ExtendedProperties(
    projectParam: param
  )
  .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
}
