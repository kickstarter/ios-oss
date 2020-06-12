import KsApi
import Prelude
import ReactiveSwift

public typealias ProjectCreatorDetailsData = (ProjectCreatorDetailsEnvelope?, isLoading: Bool)
public typealias ProjectPamphletContentData = (
  Project,
  ProjectCreatorDetailsData,
  [ProjectSummaryEnvelope.ProjectSummaryItem],
  RefTag?
)

public protocol ProjectPamphletContentViewModelInputs {
  func configureWith(value: (Project, RefTag?))
  func tappedComments()
  func tappedPledgeAnyAmount()
  func tapped(rewardOrBacking: Either<Reward, Backing>)
  func tappedUpdates()
  func tappedViewProgress(of project: Project)
  func viewDidAppear(animated: Bool)
  func viewDidLoad()
  func viewWillAppear(animated: Bool)
}

public protocol ProjectPamphletContentViewModelOutputs {
  var goToBacking: Signal<ManagePledgeViewParamConfigData, Never> { get }
  var goToComments: Signal<Project, Never> { get }
  var goToDashboard: Signal<Param, Never> { get }
  var goToRewardPledge: Signal<(Project, Reward), Never> { get }
  var goToUpdates: Signal<Project, Never> { get }
  var loadMinimalProjectIntoDataSource: Signal<Project, Never> { get }
  var loadProjectPamphletContentDataIntoDataSource: Signal<ProjectPamphletContentData, Never> { get }
}

public protocol ProjectPamphletContentViewModelType {
  var inputs: ProjectPamphletContentViewModelInputs { get }
  var outputs: ProjectPamphletContentViewModelOutputs { get }
}

public final class ProjectPamphletContentViewModel: ProjectPamphletContentViewModelType,
  ProjectPamphletContentViewModelInputs, ProjectPamphletContentViewModelOutputs {
  public init() {
    let projectAndRefTag = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let project = projectAndRefTag.map(first)

    let loadDataSourceOnSwipeCompletion = self.viewDidAppearAnimatedProperty.signal
      .filter(isTrue)
      .ignoreValues()
      .flatMap { _ in
        // NB: skip a run loop to ease the initial rendering of the cells and the swipe animation
        SignalProducer(value: ()).delay(0, on: AppEnvironment.current.scheduler)
      }

    let loadDataSourceOnModalCompletion = self.viewWillAppearAnimatedProperty.signal
      .filter(isFalse)
      .ignoreValues()

    let timeToLoadDataSource = Signal.merge(
      loadDataSourceOnSwipeCompletion,
      loadDataSourceOnModalCompletion
    )
    .take(first: 1)

    let projectCreatorDetails = project
      .take(first: 1)
      .map(\.slug)
      .switchMap { slug in
        AppEnvironment.current.apiService
          .fetchProjectCreatorDetails(query: projectCreatorDetailsQuery(withSlug: slug))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { result in (result, false) }
          .prefix(value: (nil, true))
          .demoteErrors(replaceErrorWith: (nil, false))
          .materialize()
      }

    let projectCreatorDetailsLoadingValues = projectCreatorDetails.values()
      .filter(second >>> isTrue)
      .map { $0 as ProjectCreatorDetailsData }

    let projectCreatorDetailsHasLoadedValues = projectCreatorDetails.values()
      .filter(second >>> isFalse)

    let projectCreatorDetailsExperimentValues = projectAndRefTag
      .takePairWhen(projectCreatorDetailsHasLoadedValues)
      .map { projectAndRefTag, creatorDetails in
        (projectAndRefTag.0, projectAndRefTag.1, creatorDetails.0, creatorDetails.1)
      }
      .map { project, refTag, result, isLoading -> ProjectCreatorDetailsData in
        let controlData: ProjectCreatorDetailsData = (nil, isLoading)

        // Nil result indicates loading failed, errors demoted. No need to activate experiment.
        guard result != nil else { return controlData }

        guard
          projectPageConversionCreatorDetailsExperiment(project: project, refTag: refTag) != .control
        else { return controlData }

        return (result, isLoading)
      }

    let projectCreatorDetailsValues = Signal.merge(
      projectCreatorDetailsLoadingValues,
      projectCreatorDetailsExperimentValues
    )

    let projectSummaryRequestValues = project
      .take(first: 1)
      .map(\.slug)
      .switchMap { slug in
        AppEnvironment.current.apiService
          .fetchProjectSummary(query: projectSummaryQuery(withSlug: slug))
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { $0.projectSummary }
          .demoteErrors(replaceErrorWith: [])
          .filter { !$0.isEmpty }
          .prefix(value: [])
          .materialize()
      }
      .values()

    let projectSummaryHasLoadedValues = projectSummaryRequestValues.filter { $0.isEmpty == false }

    let projectSummaryExperimentValues = projectAndRefTag
      .takePairWhen(projectSummaryHasLoadedValues)
      .map { projectAndRefTag, projectSummaryItems in
        (projectAndRefTag.0, projectAndRefTag.1, projectSummaryItems)
      }
      .map { project, refTag, projectSummaryItems -> [ProjectSummaryEnvelope.ProjectSummaryItem] in
        guard
          projectPageConversionProjectSummaryExperiment(project: project, refTag: refTag) != .control
        else { return [] }

        return projectSummaryItems
      }

    let projectSummaryValues = Signal.merge(
      projectSummaryRequestValues.take(first: 1),
      projectSummaryExperimentValues
    )

    let data = Signal.combineLatest(
      projectAndRefTag,
      projectCreatorDetailsValues,
      projectSummaryValues
    )
    .map { projectAndRefTag, creatorDetails, projectSummaryValues in
      (projectAndRefTag.0, creatorDetails, projectSummaryValues, projectAndRefTag.1)
    }

    self.loadProjectPamphletContentDataIntoDataSource = Signal.combineLatest(
      data,
      timeToLoadDataSource
    )
    .map(first)

    self.loadMinimalProjectIntoDataSource = project
      .takePairWhen(self.viewWillAppearAnimatedProperty.signal)
      .take(first: 1)
      .filter(second)
      .map(first)

    let rewardOrBackingTapped = Signal.merge(
      self.tappedRewardOrBackingProperty.signal.skipNil(),
      self.tappedPledgeAnyAmountProperty.signal.mapConst(.left(Reward.noReward))
    )

    self.goToRewardPledge = project
      .takePairWhen(rewardOrBackingTapped)
      .map(goToRewardPledgeData(forProject:rewardOrBacking:))
      .skipNil()

    self.goToBacking = project
      .takePairWhen(rewardOrBackingTapped)
      .map(goToBackingData(forProject:rewardOrBacking:))
      .skipNil()

    self.goToComments = project
      .takeWhen(self.tappedCommentsProperty.signal)

    self.goToUpdates = project
      .takeWhen(self.tappedUpdatesProperty.signal)

    self.goToDashboard = self.tappedViewProgressProperty.signal
      .skipNil()
      .map { .id($0.id) }
  }

  fileprivate let configDataProperty = MutableProperty<(Project, RefTag?)?>(nil)
  public func configureWith(value: (Project, RefTag?)) {
    self.configDataProperty.value = value
  }

  fileprivate let tappedCommentsProperty = MutableProperty(())
  public func tappedComments() {
    self.tappedCommentsProperty.value = ()
  }

  fileprivate let tappedPledgeAnyAmountProperty = MutableProperty(())
  public func tappedPledgeAnyAmount() {
    self.tappedPledgeAnyAmountProperty.value = ()
  }

  fileprivate let tappedRewardOrBackingProperty = MutableProperty<Either<Reward, Backing>?>(nil)
  public func tapped(rewardOrBacking: Either<Reward, Backing>) {
    self.tappedRewardOrBackingProperty.value = rewardOrBacking
  }

  fileprivate let tappedUpdatesProperty = MutableProperty(())
  public func tappedUpdates() {
    self.tappedUpdatesProperty.value = ()
  }

  fileprivate let tappedViewProgressProperty = MutableProperty<Project?>(nil)
  public func tappedViewProgress(of project: Project) {
    self.tappedViewProgressProperty.value = project
  }

  fileprivate let viewDidAppearAnimatedProperty = MutableProperty(false)
  public func viewDidAppear(animated: Bool) {
    self.viewDidAppearAnimatedProperty.value = animated
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let viewWillAppearAnimatedProperty = MutableProperty(false)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearAnimatedProperty.value = animated
  }

  public let goToBacking: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToComments: Signal<Project, Never>
  public let goToDashboard: Signal<Param, Never>
  public let goToRewardPledge: Signal<(Project, Reward), Never>
  public let goToUpdates: Signal<Project, Never>
  public let loadMinimalProjectIntoDataSource: Signal<Project, Never>
  public let loadProjectPamphletContentDataIntoDataSource: Signal<ProjectPamphletContentData, Never>

  public var inputs: ProjectPamphletContentViewModelInputs { return self }
  public var outputs: ProjectPamphletContentViewModelOutputs { return self }
}

private func reward(forBacking backing: Backing, inProject project: Project) -> Reward? {
  return backing.reward
    ?? project.rewards.first { $0.id == backing.rewardId }
    ?? Reward.noReward
}

private func goToRewardPledgeData(forProject project: Project, rewardOrBacking: Either<Reward, Backing>)
  -> (Project, Reward)? {
  guard project.state == .live else { return nil }

  switch rewardOrBacking {
  case let .left(reward):
    guard reward.remaining != .some(0) else { return nil }
    return (project, reward)

  case let .right(backing):
    guard let reward = reward(forBacking: backing, inProject: project) else { return nil }

    return (project, reward)
  }
}

private func goToBackingData(forProject project: Project, rewardOrBacking: Either<Reward, Backing>)
  -> ManagePledgeViewParamConfigData? {
  guard project.state != .live, let backing = rewardOrBacking.right else {
    return nil
  }

  return (projectParam: Param.slug(project.slug), backingParam: Param.id(backing.id))
}

private func projectCreatorDetailsQuery(withSlug slug: String) -> NonEmptySet<Query> {
  return Query.project(
    slug: slug,
    .id +| [
      .creator(
        .id +| [
          .backingsCount,
          .launchedProjects(
            .totalCount +| []
          )
        ]
      )
    ]
  ) +| []
}

private func projectSummaryQuery(withSlug slug: String) -> NonEmptySet<Query> {
  return Query.project(
    slug: slug,
    .id +| [
      .projectSummary(
        .question +| [
          .response
        ]
      )
    ]
  ) +| []
}

private func projectPageConversionCreatorDetailsExperiment(
  project: Project, refTag: RefTag?
) -> OptimizelyExperiment.Variant {
  let optimizelyVariant = AppEnvironment.current.optimizelyClient?
    .variant(
      for: OptimizelyExperiment.Key.nativeProjectPageConversionCreatorDetails,
      userAttributes: optimizelyUserAttributes(with: project, refTag: refTag)
    ) ?? .control

  return optimizelyVariant
}

private func projectPageConversionProjectSummaryExperiment(
  project: Project, refTag: RefTag?
) -> OptimizelyExperiment.Variant {
  let optimizelyVariant = AppEnvironment.current.optimizelyClient?
    .variant(
      for: OptimizelyExperiment.Key.nativeMeProjectSummary,
      userAttributes: optimizelyUserAttributes(with: project, refTag: refTag)
    ) ?? .control

  return optimizelyVariant
}
