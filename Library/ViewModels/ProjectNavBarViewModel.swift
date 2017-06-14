import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ProjectNavBarViewModelInputs {
  func categoryButtonTapped()
  func closeButtonTapped()
  func configureWith(project: Project, refTag: RefTag?)
  func projectImageIsVisible(_ visible: Bool)
  func projectVideoDidFinish()
  func projectVideoDidStart()
  func starButtonTapped()
  func userSessionEnded()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol ProjectNavBarViewModelOutputs {
  var backgroundOpaqueAndAnimate: Signal<(opaque: Bool, animate: Bool), NoError> { get }

  /// Emits the color of the category button's background.
  var categoryButtonBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits the category button's title text.
  var categoryButtonText: Signal<String, NoError> { get }

  /// Emits the tint color of the category button.
  var categoryButtonTintColor: Signal<UIColor, NoError> { get }

  /// Emits the color of the category button's title.
  var categoryButtonTitleColor: Signal<UIColor, NoError> { get }

  /// Emits two booleans that determine if the category is hidden, and if that change should be animated.
  var categoryHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError> { get }

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var goToLoginTout: Signal<(), NoError> { get }

  /// Emits the name of the project
  var projectName: Signal<String, NoError> { get }

  /// Emits when the project has been successfully starred and a prompt should be shown to the user.
  var showProjectStarredPrompt: Signal<Void, NoError> { get }

  /// Emits the accessibility hint for the star button.
  var starButtonAccessibilityHint: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the star button is selected.
  var starButtonSelected: Signal<Bool, NoError> { get }

  var titleHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError> { get }
}

public protocol ProjectNavBarViewModelType {
  var inputs: ProjectNavBarViewModelInputs { get }
  var outputs: ProjectNavBarViewModelOutputs { get }
}

public final class ProjectNavBarViewModel: ProjectNavBarViewModelType,
ProjectNavBarViewModelInputs, ProjectNavBarViewModelOutputs {

    public init() {
    let configuredProjectAndRefTag = Signal.combineLatest(
      self.projectAndRefTagProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

    let configuredProject = configuredProjectAndRefTag.map(first)
    let configuredRefTag = configuredProjectAndRefTag.map(second)

    let currentUser = Signal.merge([
      self.viewDidLoadProperty.signal,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal
      ])
      .map { AppEnvironment.current.currentUser }
      .skipRepeats(==)

    let loggedInUserTappedStar = currentUser
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter(isNotNil)
      .ignoreValues()

    let loggedOutUserTappedStar = currentUser
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter(isNil)
      .ignoreValues()

    // Emits only when a user logs in after having tapped the star while logged out.
    let userLoginAfterTappingStar = Signal.combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedStar
      )
      .ignoreValues()
      .take(first: 1)

    let toggleStarLens = Project.lens.personalization.isStarred %~ { !($0 ?? false) }

    let projectOnStarToggle = configuredProject
      .takeWhen(.merge(loggedInUserTappedStar, userLoginAfterTappingStar))
      .scan(nil) { accum, project in (accum ?? project) |> toggleStarLens }
      .skipNil()

    let projectOnStarToggleAndSuccess = projectOnStarToggle
      .switchMap { project in
        AppEnvironment.current.apiService.toggleStar(project)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { ($0.project, success: true) }
          .flatMapError { _ in .init(value: (project, success: false)) }
    }

    let projectOnStarToggleSuccess = projectOnStarToggleAndSuccess
      .filter(second)
      .map(first)

    let revertStarToggle = projectOnStarToggle
      .takeWhen(projectOnStarToggleAndSuccess.filter(second >>> isFalse))
      .map(toggleStarLens)

    let project = Signal
      .merge(configuredProject, projectOnStarToggle, projectOnStarToggleSuccess, revertStarToggle)

    self.categoryButtonBackgroundColor = configuredProject.map {
        discoveryGradientColors(forCategoryId: $0.category.rootId).0.withAlphaComponent(0.8)
      }
      .skipRepeats()

    self.categoryButtonText = configuredProject.map(Project.lens.category.name.view)
      .skipRepeats()

    self.categoryButtonTintColor = configuredProject.map {
      discoveryPrimaryColor(forCategoryId: $0.category.rootId)
      }
      .skipRepeats()

    self.categoryButtonTitleColor = self.categoryButtonTintColor

    self.goToLoginTout = loggedOutUserTappedStar

    self.showProjectStarredPrompt = project
      .takeWhen(self.starButtonTappedProperty.signal)
      .filter { $0.personalization.isStarred == true && !$0.endsIn48Hours(
        today: AppEnvironment.current.dateType.init().date ) }
      .filter { _ in
        !AppEnvironment.current.ubiquitousStore.hasSeenSaveProjectInProjectPage ||
        !AppEnvironment.current.userDefaults.hasSeenSaveProjectInProjectPage
      }
      .on(value: { _ in
        AppEnvironment.current.ubiquitousStore.hasSeenSaveProjectInProjectPage = true
        AppEnvironment.current.userDefaults.hasSeenSaveProjectInProjectPage = true
      })
      .ignoreValues()


//      projectOnStarToggleSuccess
//      .filter { $0.personalization.isStarred == true && !$0.endsIn48Hours(
//        today: AppEnvironment.current.dateType.init().date) }
//      .map { _ in Strings.project_star_confirmation() }

    self.starButtonSelected = project
      .map { $0.personalization.isStarred == true }
      .skipRepeats()

    self.starButtonAccessibilityHint = self.starButtonSelected
      .map { starred in starred ? Strings.Unsaves_project() : Strings.Saves_project() }

    self.projectName = project.map(Project.lens.name.view)

    let videoIsPlaying = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.projectVideoDidStartProperty.signal.mapConst(true),
      self.projectVideoDidFinishProperty.signal.mapConst(false)
    )

    let projectImageIsVisible = Signal.merge(
      self.projectImageIsVisibleProperty.signal,
      self.viewDidLoadProperty.signal.mapConst(true)
      )
      .skipRepeats()

    self.categoryHiddenAndAnimate = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((false, false)),

      Signal.combineLatest(projectImageIsVisible, videoIsPlaying)
        .map { projectImageIsVisible, videoIsPlaying in
          (videoIsPlaying ? true : !projectImageIsVisible, true)
        }
        .skip(first: 1)
      )
      .skipRepeats { $0.hidden == $1.hidden }

    self.titleHiddenAndAnimate = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((true, false)),
      self.projectImageIsVisibleProperty.signal.map { ($0, true) }
      )
      .skipRepeats { $0.hidden == $1.hidden }

    self.backgroundOpaqueAndAnimate = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((false, false)),
      self.projectImageIsVisibleProperty.signal.map { (!$0, true) }
      )
      .skipRepeats { $0.opaque == $1.opaque }

    self.dismissViewController = self.closeButtonTappedProperty.signal

    Signal.combineLatest(project, configuredRefTag)
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeValues { project, refTag in
        AppEnvironment.current.koala.trackClosedProjectPage(project, refTag: refTag, gestureType: .tap)
    }

    projectOnStarToggleSuccess
      .observeValues { AppEnvironment.current.koala.trackProjectStar($0, context: .project) }
  }
  // swiftlint:enable function_body_length

  fileprivate let projectAndRefTagProperty = MutableProperty<(Project, RefTag?)?>(nil)
  public func configureWith(project: Project, refTag: RefTag?) {
    self.projectAndRefTagProperty.value = (project, refTag)
  }

  fileprivate let closeButtonTappedProperty = MutableProperty()
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  fileprivate let projectImageIsVisibleProperty = MutableProperty(false)
  public func projectImageIsVisible(_ visible: Bool) {
    self.projectImageIsVisibleProperty.value = visible
  }

  fileprivate let projectVideoDidFinishProperty = MutableProperty()
  public func projectVideoDidFinish() {
    self.projectVideoDidFinishProperty.value = ()
  }

  fileprivate let projectVideoDidStartProperty = MutableProperty()
  public func projectVideoDidStart() {
    self.projectVideoDidStartProperty.value = ()
  }

  public func categoryButtonTapped() {
  }

  fileprivate let starButtonTappedProperty = MutableProperty()
  public func starButtonTapped() {
    self.starButtonTappedProperty.value = ()
  }

  fileprivate let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let backgroundOpaqueAndAnimate: Signal<(opaque: Bool, animate: Bool), NoError>
  public let categoryButtonBackgroundColor: Signal<UIColor, NoError>
  public let categoryButtonText: Signal<String, NoError>
  public let categoryButtonTintColor: Signal<UIColor, NoError>
  public let categoryButtonTitleColor: Signal<UIColor, NoError>
  public let categoryHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>
  public let dismissViewController: Signal<(), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let projectName: Signal<String, NoError>
  public let showProjectStarredPrompt: Signal<Void, NoError>
  public let starButtonAccessibilityHint: Signal<String, NoError>
  public let starButtonSelected: Signal<Bool, NoError>
  public let titleHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>

  public var inputs: ProjectNavBarViewModelInputs { return self }
  public var outputs: ProjectNavBarViewModelOutputs { return self }
}
