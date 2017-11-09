import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ProjectNavBarViewModelInputs {
  func categoryButtonTapped()
  func closeButtonTapped()
  func configureWith(project: Project, refTag: RefTag?)
  func projectPageDidScrollToTop(_ didScrollToTop: Bool)
  func projectImageIsVisible(_ visible: Bool)
  func projectVideoDidFinish()
  func projectVideoDidStart()
  func saveButtonTapped()
  func userSessionEnded()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol ProjectNavBarViewModelOutputs {
  var backgroundOpaqueAndAnimate: Signal<(opaque: Bool, animate: Bool), NoError> { get }

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

  /// Emits a boolean that determines if the navBar should show dropShadow.
  var navBarShadowVisible: Signal<Bool, NoError> { get }

  /// Emits a project.
  var postNotificationWithProject: Signal<Project, NoError> { get }

  /// Emits the name of the project
  var projectName: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the save button is enabled.
  var saveButtonEnabled: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the save button is selected.
  var saveButtonSelected: Signal<Bool, NoError> { get }

  /// Emits when the project has been successfully saved and a prompt should be shown to the user.
  var showProjectSavedPrompt: Signal<Void, NoError> { get }

  /// Emits the accessibility hint for the star button.
  var saveButtonAccessibilityValue: Signal<String, NoError> { get }

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

    let loggedInUserTappedSaveButton = currentUser
      .takeWhen(self.saveButtonTappedProperty.signal)
      .filter(isNotNil)
      .ignoreValues()

    let loggedOutUserTappedSaveButton = currentUser
      .takeWhen(self.saveButtonTappedProperty.signal)
      .filter(isNil)
      .ignoreValues()

    // Emits only when a user logs in after having tapped the save/heart while logged out.
    let userLoginAfterTappingSaveButton = Signal.combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedSaveButton
      )
      .ignoreValues()
      .take(first: 1)

    let toggleSaveLens = Project.lens.personalization.isStarred %~ { !($0 ?? false) }

    let projectOnSaveButtonToggle = configuredProject
      .takeWhen(.merge(loggedInUserTappedSaveButton, userLoginAfterTappingSaveButton))
      .scan(nil) { accum, project in (accum ?? project) |> toggleSaveLens }
      .skipNil()

    let isLoading = MutableProperty(false)

    let projectOnSaveButtonToggleAndSuccess = projectOnSaveButtonToggle
      .switchMap { project in
        AppEnvironment.current.apiService.toggleStar(project)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(
            starting: { isLoading.value = true },
            terminated: { isLoading.value = false}
          )
          .map { ($0.project, success: true) }
          .flatMapError { _ in .init(value: (project, success: false)) }
    }

    let projectOnSaveButtonToggleSuccess = projectOnSaveButtonToggleAndSuccess
      .filter(second)
      .map(first)

    let revertSaveButtonToggle = projectOnSaveButtonToggle
      .takeWhen(projectOnSaveButtonToggleAndSuccess.filter(second >>> isFalse))
      .map(toggleSaveLens)

    let project = Signal.merge(
      configuredProject,
      projectOnSaveButtonToggle,
      projectOnSaveButtonToggleSuccess,
      revertSaveButtonToggle)

    self.categoryButtonText = configuredProject.map(Project.lens.category.name.view)
      .skipRepeats()

    self.categoryButtonTintColor = configuredProject.mapConst(discoveryPrimaryColor())

    self.categoryButtonTitleColor = self.categoryButtonTintColor

    self.goToLoginTout = loggedOutUserTappedSaveButton

    self.showProjectSavedPrompt = project
      .takeWhen(self.saveButtonTappedProperty.signal)
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

    self.saveButtonSelected = project
      .map { $0.personalization.isStarred == true }
      .skipRepeats()

    self.saveButtonAccessibilityValue = self.saveButtonSelected
      .map { starred in starred ? Strings.Saved() : Strings.Unsaved() }

    self.projectName = project.map(Project.lens.name.view)

    let videoIsPlaying = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.projectVideoDidStartProperty.signal.mapConst(true),
      self.projectVideoDidFinishProperty.signal.mapConst(false)
    )

    self.saveButtonEnabled = isLoading.signal.map(negate)
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

    self.navBarShadowVisible = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(true),
      self.projectPageDidScrollToTopProperty.signal
      )
      .skipRepeats()

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

    self.postNotificationWithProject = project
      .takeWhen(self.saveButtonTappedProperty.signal)

    Signal.combineLatest(project, configuredRefTag)
      .takeWhen(self.closeButtonTappedProperty.signal)
      .observeValues { project, refTag in
        AppEnvironment.current.koala.trackClosedProjectPage(project, refTag: refTag, gestureType: .tap)
    }

    projectOnSaveButtonToggleSuccess
      .observeValues { AppEnvironment.current.koala.trackProjectSave($0, context: .project) }
  }

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

  fileprivate let projectPageDidScrollToTopProperty = MutableProperty(false)
  public func projectPageDidScrollToTop(_ didScrollToTop: Bool) {
    self.projectPageDidScrollToTopProperty.value = didScrollToTop
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

  fileprivate let saveButtonTappedProperty = MutableProperty()
  public func saveButtonTapped() {
    self.saveButtonTappedProperty.value = ()
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
  public let categoryButtonText: Signal<String, NoError>
  public let categoryButtonTintColor: Signal<UIColor, NoError>
  public let categoryButtonTitleColor: Signal<UIColor, NoError>
  public let categoryHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>
  public let dismissViewController: Signal<(), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let navBarShadowVisible: Signal<Bool, NoError>
  public let postNotificationWithProject: Signal<Project, NoError>
  public let projectName: Signal<String, NoError>
  public let saveButtonEnabled: Signal<Bool, NoError>
  public let saveButtonSelected: Signal<Bool, NoError>
  public let showProjectSavedPrompt: Signal<Void, NoError>
  public let saveButtonAccessibilityValue: Signal<String, NoError>
  public let titleHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>

  public var inputs: ProjectNavBarViewModelInputs { return self }
  public var outputs: ProjectNavBarViewModelOutputs { return self }
}
