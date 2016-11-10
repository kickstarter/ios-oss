import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectNavigatorViewModelInputs {
  /// Call with the config data give to the view.
  func configureWith(project project: Project, initialPlaylist: [Project], refTag: RefTag?)

  /// Call when the UIPageViewController finishes transitioning.
  func pageTransition(completed completed: Bool)

  /// Call with panning data.
  func panning(contentOffset contentOffset: CGPoint,
                             translation: CGPoint,
                             velocity: CGPoint,
                             isDragging: Bool)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the UIPageViewController begins a transition sequence.
  func willTransition(toPage nextPage: Int)
}

public protocol ProjectNavigatorViewModelOutputs {
  /// Emits when the transition animator should be canceled.
  var cancelInteractiveTransition: Signal<(), NoError> { get }

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), NoError> { get }

  /// Emits when the transition animator should be finished.
  var finishInteractiveTransition: Signal<(), NoError> { get }

  /// Emits when the initial view controllers should be set on the page controller.
  var setInitialPagerViewController: Signal<(), NoError> { get }

  /// Emits when the controller's `setNeedsStatusBarAppearanceUpdate` method needs to be called
  var setNeedsStatusBarAppearanceUpdate: Signal<(), NoError> { get }

  /// Emits when the transition animator needs to have its `isInFlight` property updated.
  var setTransitionAnimatorIsInFlight: Signal<Bool, NoError> { get }

  /// Emits when the data source's playlist and project needs to be updated.
  var updateDataSourcePlaylist: Signal<(Project?, [Project]), NoError> { get }

  /// Emits when the transition animator should be updated.
  var updateInteractiveTransition: Signal<CGFloat, NoError> { get }
}

public protocol ProjectNavigatorViewModelType {
  var inputs: ProjectNavigatorViewModelInputs { get }
  var outputs: ProjectNavigatorViewModelOutputs { get }
}

public final class ProjectNavigatorViewModel: ProjectNavigatorViewModelType,
ProjectNavigatorViewModelInputs, ProjectNavigatorViewModelOutputs {

  // swiftlint:disable:next function_body_length
  public init() {
    let configData = combineLatest(
      self.configDataProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    self.updateDataSourcePlaylist = configData
      .map { ($0.project, $0.initialPlaylist) }

    let swipedToPage = self.willTransitionToPageProperty.signal
      .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))

    self.setNeedsStatusBarAppearanceUpdate = swipedToPage.ignoreValues()

    let panningData = self.panningDataProperty.signal.ignoreNil()

    let transitionPhase = panningData
      .scan(TransitionPhase.none) { phase, data in
        if data.contentOffset.y > 0 {
          return phase == .none ? .none : .canceling
        }
        if data.isDragging && data.translation.y > 0 && !phase.active {
          return .started
        }
        if data.isDragging && data.translation.y > 0 && phase.active {
          return .updating
        }
        if data.isDragging && data.translation.y < 0 && phase.active {
          return .canceling
        }
        if !data.isDragging && data.translation.y > 0 && phase.active {
          return data.velocity.y > 0 ? .finishing : .canceling
        }
        return phase
    }

    self.setInitialPagerViewController = self.viewDidLoadProperty.signal

    self.dismissViewController = transitionPhase
      .map { $0 == .started }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    self.cancelInteractiveTransition = transitionPhase
      .map { $0 == .canceling }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    self.updateInteractiveTransition = zip(panningData, transitionPhase)
      .filter { _, phase in phase == .updating || phase == .started }
      .map { data, _ in data.translation.y }

    self.finishInteractiveTransition = transitionPhase
      .map { $0 == .finishing }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    self.setTransitionAnimatorIsInFlight = transitionPhase
      .map { $0 == .started || $0 == .updating }
      .skipRepeats()

    configData
      .takePairWhen(swipedToPage)
      .observeNext { configData, idx in
        AppEnvironment.current.koala.trackSwipedProject(
          configData.initialPlaylist[idx],
          refTag: configData.refTag
        )
    }

    configData
      .takeWhen(self.finishInteractiveTransition)
      .observeNext { data in
        AppEnvironment.current.koala.trackClosedProjectPage(data.project, gestureType: .swipe)
    }
  }

  private let configDataProperty = MutableProperty<ConfigData?>(nil)
  public func configureWith(project project: Project, initialPlaylist: [Project], refTag: RefTag?) {
    self.configDataProperty.value = ConfigData(
      initialPlaylist: initialPlaylist, project: project, refTag: refTag
    )
  }

  private let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let willTransitionToPageProperty = MutableProperty<Int>(0)
  public func willTransition(toPage nextPage: Int) {
    self.willTransitionToPageProperty.value = nextPage
  }

  private let panningDataProperty = MutableProperty<PanningData?>(nil)
  public func panning(contentOffset contentOffset: CGPoint,
                                    translation: CGPoint,
                                    velocity: CGPoint,
                                    isDragging: Bool) {
    self.panningDataProperty.value = PanningData(contentOffset: contentOffset,
                                                 isDragging: isDragging,
                                                 translation: translation,
                                                 velocity: velocity)
  }

  public let cancelInteractiveTransition: Signal<(), NoError>
  public let dismissViewController: Signal<(), NoError>
  public let finishInteractiveTransition: Signal<(), NoError>
  public let setInitialPagerViewController: Signal<(), NoError>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), NoError>
  public let setTransitionAnimatorIsInFlight: Signal<Bool, NoError>
  public let updateInteractiveTransition: Signal<CGFloat, NoError>
  public let updateDataSourcePlaylist: Signal<(Project?, [Project]), NoError>

  public var inputs: ProjectNavigatorViewModelInputs { return self }
  public var outputs: ProjectNavigatorViewModelOutputs { return self }
}

private struct ConfigData {
  private let initialPlaylist: [Project]
  private let project: Project
  private let refTag: RefTag?
}

private struct PanningData {
  private let contentOffset: CGPoint
  private let isDragging: Bool
  private let translation: CGPoint
  private let velocity: CGPoint
}

private enum TransitionPhase {
  case none
  case started
  case updating
  case canceling
  case finishing

  private var active: Bool {
    return self == .started || self == .updating
  }
}
