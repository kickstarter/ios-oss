import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ProjectNavigatorViewModelInputs {
  /// Call with the config data give to the view.
  func configureWith(project: Project, refTag: RefTag)

  /// Call when the UIPageViewController finishes transitioning.
  func pageTransition(completed: Bool)

  /// Call with panning data.
  func panning(contentOffset: CGPoint,
                             translation: CGPoint,
                             velocity: CGPoint,
                             isDragging: Bool)

  /// Call when the view loads.
  func viewDidLoad()

  /// Call when the UIPageViewController begins a transition sequence to a project.
  func willTransition(toProject project: Project)
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
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let swipedToProject = self.willTransitionToProjectProperty.signal.skipNil()
      .takeWhen(self.pageTransitionCompletedProperty.signal.filter(isTrue))

    let currentProject = Signal.merge(
      configData.map { $0.project },
      swipedToProject
    )

    self.setNeedsStatusBarAppearanceUpdate = swipedToProject.ignoreValues()

    let panningData = self.panningDataProperty.signal.skipNil()

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

    configData
      .takePairWhen(swipedToProject)
      .observeValues { configData, project in
        AppEnvironment.current.koala.trackSwipedProject(project, refTag: configData.refTag)
    }

    Signal.combineLatest(configData, currentProject)
      .takeWhen(self.finishInteractiveTransition)
      .observeValues { configData, project in
        AppEnvironment.current.koala.trackClosedProjectPage(
          project,
          refTag: configData.refTag,
          gestureType: .swipe
        )
    }
  }

  fileprivate let configDataProperty = MutableProperty<ConfigData?>(nil)
  public func configureWith(project: Project, refTag: RefTag) {
    self.configDataProperty.value = ConfigData(project: project, refTag: refTag)
  }

  fileprivate let pageTransitionCompletedProperty = MutableProperty(false)
  public func pageTransition(completed: Bool) {
    self.pageTransitionCompletedProperty.value = completed
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let willTransitionToProjectProperty = MutableProperty<Project?>(nil)
  public func willTransition(toProject project: Project) {
    self.willTransitionToProjectProperty.value = project
  }

  fileprivate let panningDataProperty = MutableProperty<PanningData?>(nil)
  public func panning(contentOffset: CGPoint,
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
