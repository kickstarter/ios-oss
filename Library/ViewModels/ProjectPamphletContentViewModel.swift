import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectPamphletContentViewModelInputs {
  func configureWith(project project: Project)
  func tappedComments()
  func tappedPledgeAnyAmount()
  func tapped(rewardOrBacking rewardOrBacking: Either<Reward, Backing>)
  func tappedUpdates()
  func viewDidAppear(animated animated: Bool)
  func viewDidLoad()
  func viewWillAppear(animated animated: Bool)
}

public protocol ProjectPamphletContentViewModelOutputs {
  var goToBacking: Signal<Project, NoError> { get }
  var goToComments: Signal<Project, NoError> { get }
  var goToRewardPledge: Signal<(Project, Reward), NoError> { get }
  var goToUpdates: Signal<Project, NoError> { get }
  var loadMinimalProjectIntoDataSource: Signal<Project, NoError> { get }
  var loadProjectIntoDataSource: Signal<Project, NoError> { get }
}

public protocol ProjectPamphletContentViewModelType {
  var inputs: ProjectPamphletContentViewModelInputs { get }
  var outputs: ProjectPamphletContentViewModelOutputs { get }
}

public final class ProjectPamphletContentViewModel: ProjectPamphletContentViewModelType,
ProjectPamphletContentViewModelInputs, ProjectPamphletContentViewModelOutputs {

  public init() {
    let projectOnViewDidLoad = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let projectOnViewDidAppear = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidAppearAnimated.signal.take(1)
      )
      .map(first)

    self.loadProjectIntoDataSource = projectOnViewDidAppear

    self.loadMinimalProjectIntoDataSource = .empty

    let rewardOrBackingTapped = Signal.merge(
      self.tappedRewardOrBackingProperty.signal.ignoreNil(),
      self.tappedPledgeAnyAmountProperty.signal.mapConst(.left(Reward.noReward))
    )

    self.goToRewardPledge = projectOnViewDidLoad
      .takePairWhen(rewardOrBackingTapped)
      .map(goToRewardPledgeData(forProject:rewardOrBacking:))
      .ignoreNil()

    self.goToBacking = projectOnViewDidLoad.takePairWhen(rewardOrBackingTapped)
      .map(goToBackingData(forProject:rewardOrBacking:))
      .ignoreNil()

    self.goToComments = projectOnViewDidLoad
      .takeWhen(self.tappedCommentsProperty.signal)

    self.goToUpdates = projectOnViewDidLoad
      .takeWhen(self.tappedUpdatesProperty.signal)
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let tappedCommentsProperty = MutableProperty()
  public func tappedComments() {
    self.tappedCommentsProperty.value = ()
  }

  private let tappedPledgeAnyAmountProperty = MutableProperty()
  public func tappedPledgeAnyAmount() {
    self.tappedPledgeAnyAmountProperty.value = ()
  }

  private let tappedRewardOrBackingProperty = MutableProperty<Either<Reward, Backing>?>(nil)
  public func tapped(rewardOrBacking rewardOrBacking: Either<Reward, Backing>) {
    self.tappedRewardOrBackingProperty.value = rewardOrBacking
  }

  private let tappedUpdatesProperty = MutableProperty()
  public func tappedUpdates() {
    self.tappedUpdatesProperty.value = ()
  }

  private let viewDidAppearAnimated = MutableProperty(false)
  public func viewDidAppear(animated animated: Bool) {
    self.viewDidAppearAnimated.value = animated
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearAnimated = MutableProperty(false)
  public func viewWillAppear(animated animated: Bool) {
    self.viewWillAppearAnimated.value = animated
  }

  public let goToBacking: Signal<Project, NoError>
  public let goToComments: Signal<Project, NoError>
  public let goToRewardPledge: Signal<(Project, Reward), NoError>
  public let goToUpdates: Signal<Project, NoError>
  public let loadMinimalProjectIntoDataSource: Signal<Project, NoError>
  public let loadProjectIntoDataSource: Signal<Project, NoError>

  public var inputs: ProjectPamphletContentViewModelInputs { return self }
  public var outputs: ProjectPamphletContentViewModelOutputs { return self }
}

private func reward(forBacking backing: Backing, inProject project: Project) -> Reward? {

  return backing.reward
    ?? project.rewards.filter { $0.id == backing.rewardId }.first
    ?? Reward.noReward
}

private func goToRewardPledgeData(forProject project: Project, rewardOrBacking: Either<Reward, Backing>)
  -> (Project, Reward)? {

    guard project.state == .live else { return nil }

    switch rewardOrBacking {
    case let .left(reward):
      guard reward.remaining != .Some(0) else { return nil }
      return (project, reward)

    case let .right(backing):
      guard let reward = reward(forBacking: backing, inProject: project) else { return nil }

      return (project, reward)
    }
}

private func goToBackingData(forProject project: Project, rewardOrBacking: Either<Reward, Backing>)
  -> Project? {

    guard project.state != .live && rewardOrBacking.right != nil else {
      return nil
    }

    return project
}
