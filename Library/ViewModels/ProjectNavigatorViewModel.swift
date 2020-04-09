import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectNavigatorViewModelInputs {
  /// Call with the config data given to the view.
  func configureWith(project: Project, refTag: RefTag)

  /// Call when the UIPageViewController finishes transitioning with previous index value.
  func pageTransition(completed: Bool, from index: Int?)

  /// Call with panning data.
  func panning(
    contentOffset: CGPoint,
    translation: CGPoint,
    velocity: CGPoint,
    isDragging: Bool
  )

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the UIPageViewController begins a transition sequence to a project with its index.
  func willTransition(toProject project: Project, at index: Int?)
}

public protocol ProjectNavigatorViewModelOutputs {
  /// Emits when the transition animator should be canceled.
  var cancelInteractiveTransition: Signal<(), Never> { get }

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), Never> { get }

  /// Emits when the transition animator should be finished.
  var finishInteractiveTransition: Signal<(), Never> { get }

  /// Emits when to notify delegate that a transition was completed with the current row index.
  var notifyDelegateTransitionedToProjectIndex: Signal<Int, Never> { get }

  /// Emits when the initial view controllers should be set on the page controller.
  var setInitialPagerViewController: Signal<(), Never> { get }

  /// Emits when the controller's `setNeedsStatusBarAppearanceUpdate` method needs to be called
  var setNeedsStatusBarAppearanceUpdate: Signal<(), Never> { get }

  /// Emits when the transition animator needs to have its `isInFlight` property updated.
  var setTransitionAnimatorIsInFlight: Signal<Bool, Never> { get }

  /// Emits when the transition animator should be updated.
  var updateInteractiveTransition: Signal<CGFloat, Never> { get }
}

public protocol ProjectNavigatorViewModelType {
  var inputs: ProjectNavigatorViewModelInputs { get }
  var outputs: ProjectNavigatorViewModelOutputs { get }
}

public final class ProjectNavigatorViewModel: ProjectNavigatorViewModelType,
  ProjectNavigatorViewModelInputs, ProjectNavigatorViewModelOutputs {
  public init() {
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let pageTransitionCompletedFromIndex = self.pageTransitionCompletedFromIndexProperty.signal.skipNil()
      .filter { completed, _ in completed }

    let swipedToProject = self.willTransitionToProjectAtIndexProperty.signal.skipNil()
      .takeWhen(pageTransitionCompletedFromIndex)
      .map(first)

    self.setNeedsStatusBarAppearanceUpdate = swipedToProject.ignoreValues()

    let panningData = self.panningDataProperty.signal.skipNil()

    let transitionPhase = panningData
      .scan(TransitionPhase.none) { phase, data -> TransitionPhase in
        if data.contentOffset.y > 0 {
          return phase == .none ? .none : .canceling
        }
        if data.isDragging, data.translation.y > 0, !phase.active {
          return .started
        }
        if data.isDragging, data.translation.y > 0, phase.active {
          return .updating
        }
        if data.isDragging, data.translation.y < 0, phase.active {
          return .canceling
        }
        if !data.isDragging, data.translation.y > 0, phase.active {
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

    self.updateInteractiveTransition = Signal.zip(panningData, transitionPhase)
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

    let swipedToProjectAtIndexFromIndex = self.willTransitionToProjectAtIndexProperty.signal.skipNil()
      .takePairWhen(pageTransitionCompletedFromIndex.map(second))
      .map { (project: $0.0, currentIndex: $0.1, previousIndex: $1) }

    self.notifyDelegateTransitionedToProjectIndex = swipedToProjectAtIndexFromIndex
      .map { $0.currentIndex }
      .skipNil()

    configData
      .takePairWhen(swipedToProjectAtIndexFromIndex)
      .observeValues { configData, pii in
        AppEnvironment.current.koala.trackSwipedProject(pii.project, refTag: configData.refTag)
      }
  }

  fileprivate let configDataProperty = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project, refTag: RefTag) {
    self.configDataProperty.value = ConfigData(project: project, refTag: refTag)
  }

  fileprivate let pageTransitionCompletedFromIndexProperty = MutableProperty<(Bool, Int?)?>(nil)
  public func pageTransition(completed: Bool, from index: Int?) {
    self.pageTransitionCompletedFromIndexProperty.value = (completed, index)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let willTransitionToProjectAtIndexProperty = MutableProperty<(Project, Int?)?>(nil)
  public func willTransition(toProject project: Project, at index: Int?) {
    self.willTransitionToProjectAtIndexProperty.value = (project, index)
  }

  fileprivate let panningDataProperty = MutableProperty<PanningData?>(nil)
  public func panning(
    contentOffset: CGPoint,
    translation: CGPoint,
    velocity: CGPoint,
    isDragging: Bool
  ) {
    self.panningDataProperty.value = PanningData(
      contentOffset: contentOffset,
      isDragging: isDragging,
      translation: translation,
      velocity: velocity
    )
  }

  public let cancelInteractiveTransition: Signal<(), Never>
  public let dismissViewController: Signal<(), Never>
  public let finishInteractiveTransition: Signal<(), Never>
  public let notifyDelegateTransitionedToProjectIndex: Signal<Int, Never>
  public let setInitialPagerViewController: Signal<(), Never>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), Never>
  public let setTransitionAnimatorIsInFlight: Signal<Bool, Never>
  public let updateInteractiveTransition: Signal<CGFloat, Never>

  public var inputs: ProjectNavigatorViewModelInputs { return self }
  public var outputs: ProjectNavigatorViewModelOutputs { return self }
}

private struct ConfigData {
  fileprivate let project: Project
  fileprivate let refTag: RefTag
}

private struct PanningData {
  fileprivate let contentOffset: CGPoint
  fileprivate let isDragging: Bool
  fileprivate let translation: CGPoint
  fileprivate let velocity: CGPoint
}

private enum TransitionPhase {
  case none
  case started
  case updating
  case canceling
  case finishing

  fileprivate var active: Bool {
    return self == .started || self == .updating
  }
}
