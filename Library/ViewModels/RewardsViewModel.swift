import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol RewardsViewModelInputs {
  func configureWith(project project: Project)
  func tapped(reward reward: Reward)
  func transferredHeaderView(atContentOffset contentOffset: CGPoint?)
  func viewDidLayoutSubviews(contentSize contentSize: CGSize)
  func viewDidLoad()
}

public protocol RewardsViewModelOutputs {
  var goToRewardPledge: Signal<(Project, Reward), NoError> { get }
  var layoutHeaderView: Signal<CGPoint?, NoError> { get }
  var loadProjectIntoDataSource: Signal<Project, NoError> { get }
}

public protocol RewardsViewModelType {
  var inputs: RewardsViewModelInputs { get }
  var outputs: RewardsViewModelOutputs { get }
}

public final class RewardsViewModel: RewardsViewModelType, RewardsViewModelInputs, RewardsViewModelOutputs {

  public init() {
    let project = combineLatest(self.projectProperty.signal.ignoreNil(), self.viewDidLoadProperty.signal)
      .map(first)

    self.loadProjectIntoDataSource = project
      .takeWhen(self.transferredHeaderViewProperty.signal.take(1))

    self.layoutHeaderView = Signal.merge(
      self.transferredHeaderViewProperty.signal,
      self.viewDidLayoutSubviewsContentSizeProperty.signal.skipRepeats().mapConst(nil)
    )

    self.goToRewardPledge = project
      .takePairWhen(self.tappedRewardProperty.signal.ignoreNil())
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let transferredHeaderViewProperty = MutableProperty<CGPoint?>(nil)
  public func transferredHeaderView(atContentOffset contentOffset: CGPoint?) {
    self.transferredHeaderViewProperty.value = contentOffset
  }

  private let tappedRewardProperty = MutableProperty<Reward?>(nil)
  public func tapped(reward reward: Reward) {
    self.tappedRewardProperty.value = reward
  }

  private let viewDidLayoutSubviewsContentSizeProperty = MutableProperty(CGSize.zero)
  public func viewDidLayoutSubviews(contentSize contentSize: CGSize) {
    self.viewDidLayoutSubviewsContentSizeProperty.value = contentSize
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let goToRewardPledge: Signal<(Project, Reward), NoError>
  public let layoutHeaderView: Signal<CGPoint?, NoError>
  public let loadProjectIntoDataSource: Signal<Project, NoError>

  public var inputs: RewardsViewModelInputs { return self }
  public var outputs: RewardsViewModelOutputs { return self }
}
