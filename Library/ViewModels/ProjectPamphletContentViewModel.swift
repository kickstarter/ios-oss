import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectPamphletContentViewModelInputs {
  func configureWith(project project: Project)
  func tappedComments()
  func tappedPledgeAnyAmount()
  func tapped(reward reward: Reward)
  func tappedUpdates()
  func viewDidLayoutSubviews(contentSize contentSize: CGSize)
  func viewDidLoad()
}

public protocol ProjectPamphletContentViewModelOutputs {
  var goToBacking: Signal<Project, NoError> { get }
  var goToComments: Signal<Project, NoError> { get }
  var goToRewardPledge: Signal<(Project, Reward), NoError> { get }
  var goToUpdates: Signal<Project, NoError> { get }
  var loadProjectIntoDataSource: Signal<Project, NoError> { get }
}

public protocol ProjectPamphletContentViewModelType {
  var inputs: ProjectPamphletContentViewModelInputs { get }
  var outputs: ProjectPamphletContentViewModelOutputs { get }
}

public final class ProjectPamphletContentViewModel: ProjectPamphletContentViewModelType,
ProjectPamphletContentViewModelInputs, ProjectPamphletContentViewModelOutputs {

  public init() {
    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    self.loadProjectIntoDataSource = combineLatest(project, self.viewDidLoadProperty.signal)
      .map(first)

    let rewardTapped = Signal.merge(
      self.tappedRewardProperty.signal.ignoreNil(),
      self.tappedPledgeAnyAmountProperty.signal.mapConst(Reward.noReward)
    )
    self.goToRewardPledge = project
      .takePairWhen(rewardTapped)
      .filter { project, reward in project.state == .live && reward.remaining != 0 }

    self.goToBacking = project.takePairWhen(rewardTapped)
      .filter(shouldGoToBacking(forProject:reward:))
      .map(first)

    self.goToComments = project
      .takeWhen(self.tappedCommentsProperty.signal)

    self.goToUpdates = project
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

  private let tappedRewardProperty = MutableProperty<Reward?>(nil)
  public func tapped(reward reward: Reward) {
    self.tappedRewardProperty.value = reward
  }

  private let tappedUpdatesProperty = MutableProperty()
  public func tappedUpdates() {
    self.tappedUpdatesProperty.value = ()
  }

  private let viewDidLayoutSubviewsContentSizeProperty = MutableProperty(CGSize.zero)
  public func viewDidLayoutSubviews(contentSize contentSize: CGSize) {
    self.viewDidLayoutSubviewsContentSizeProperty.value = contentSize
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToBacking: Signal<Project, NoError>
  public let goToComments: Signal<Project, NoError>
  public let goToRewardPledge: Signal<(Project, Reward), NoError>
  public let goToUpdates: Signal<Project, NoError>
  public let loadProjectIntoDataSource: Signal<Project, NoError>

  public var inputs: ProjectPamphletContentViewModelInputs { return self }
  public var outputs: ProjectPamphletContentViewModelOutputs { return self }
}

private func shouldGoToBacking(forProject project: Project, reward: Reward) -> Bool {
  return project.state != .live
    && (
      reward == project.personalization.backing?.reward
        || reward.id == project.personalization.backing?.rewardId
  )
}
