import KsApi
import Prelude
import ReactiveSwift

public typealias ProjectPamphletContentData = (Project, RefTag?)

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

    self.loadProjectPamphletContentDataIntoDataSource = Signal.combineLatest(
      projectAndRefTag,
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
