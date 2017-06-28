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
  func heartButtonTapped()
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

  /// Emits when the project has been successfully saved and a prompt should be shown to the user.
  var showProjectSavedPrompt: Signal<Void, NoError> { get }

  /// Emits the accessibility hint for the star button.
  var starButtonAccessibilityHint: Signal<String, NoError> { get } // check this after new strings

  /// Emits a boolean that determines if the heart button is selected.
  var heartButtonSelected: Signal<Bool, NoError> { get }

  var titleHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError> { get }

  var project: Signal<Project, NoError> { get }

  var heartButtonEnabled: Signal<Bool, NoError> { get }
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

    let loggedInUserTappedHeart = currentUser
      .takeWhen(self.heartButtonTappedProperty.signal)
      .filter(isNotNil)
      .ignoreValues()

    let loggedOutUserTappedHeart = currentUser
      .takeWhen(self.heartButtonTappedProperty.signal)
      .filter(isNil)
      .ignoreValues()

    // Emits only when a user logs in after having tapped the star while logged out.
    let userLoginAfterTappingHeart = Signal.combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedHeart
      )
      .ignoreValues()
      .take(first: 1)

    let toggleHeartLens = Project.lens.personalization.isStarred %~ { !($0 ?? false) }

    let projectOnHeartToggle = configuredProject
      .takeWhen(.merge(loggedInUserTappedHeart, userLoginAfterTappingHeart))
      .scan(nil) { accum, project in (accum ?? project) |> toggleHeartLens }
      .skipNil()

    let isLoading = MutableProperty(false)

    let projectOnHeartToggleAndSuccess = projectOnHeartToggle
      .switchMap { project in
        AppEnvironment.current.apiService.toggleStar(project)
          .on(
            starting: { isLoading.value = true },
            terminated: { isLoading.value = false}
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { ($0.project, success: true) }
          .flatMapError { _ in .init(value: (project, success: false)) }
    }

    let projectOnHeartToggleSuccess = projectOnHeartToggleAndSuccess
      .filter(second)
      .map(first)

    let revertStarToggle = projectOnHeartToggle
      .takeWhen(projectOnHeartToggleAndSuccess.filter(second >>> isFalse))
      .map(toggleHeartLens)

    let project = Signal
      .merge(configuredProject, projectOnHeartToggle, projectOnHeartToggleSuccess, revertStarToggle)

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

    self.goToLoginTout = loggedOutUserTappedHeart

    self.showProjectSavedPrompt = project
      .takeWhen(self.heartButtonTappedProperty.signal)
      .filter { $0.personalization.isStarred == true && !$0.endsIn48Hours(
        today: AppEnvironment.current.dateType.init().date ) }
      .filter { _ in
        !AppEnvironment.current.ubiquitousStore.hasSeenSaveProjectAlert ||
        !AppEnvironment.current.userDefaults.hasSeenSaveProjectAlert
      }
      .on(value: { _ in
        AppEnvironment.current.ubiquitousStore.hasSeenSaveProjectAlert = true
        AppEnvironment.current.userDefaults.hasSeenSaveProjectAlert = true
      })
      .ignoreValues()

    self.heartButtonSelected = project
      .map { $0.personalization.isStarred == true }
      .skipRepeats()

    self.starButtonAccessibilityHint = self.heartButtonSelected
      .map { starred in starred ? Strings.Unsaves_project() : Strings.Saves_project() }

    self.projectName = project.map(Project.lens.name.view)

    let videoIsPlaying = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.projectVideoDidStartProperty.signal.mapConst(true),
      self.projectVideoDidFinishProperty.signal.mapConst(false)
    )

    self.heartButtonEnabled = isLoading.signal.map(negate)
      .skipRepeats()

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

    self.project = project
      .takeWhen(self.heartButtonTappedProperty.signal)

    Signal.combineLatest(project, configuredRefTag)
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeValues { project, refTag in
        AppEnvironment.current.koala.trackClosedProjectPage(project, refTag: refTag, gestureType: .tap)
    }

    projectOnHeartToggleSuccess
      .observeValues { AppEnvironment.current.koala.trackProjectSave($0, context: .project) }
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

  fileprivate let heartButtonTappedProperty = MutableProperty()
  public func heartButtonTapped() {
    self.heartButtonTappedProperty.value = ()
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
  public let showProjectSavedPrompt: Signal<Void, NoError>
  public let starButtonAccessibilityHint: Signal<String, NoError>
  public let heartButtonSelected: Signal<Bool, NoError>
  public let heartButtonEnabled: Signal<Bool, NoError>
  public let titleHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>

  public let project: Signal<Project, NoError>

  public var inputs: ProjectNavBarViewModelInputs { return self }
  public var outputs: ProjectNavBarViewModelOutputs { return self }
}
