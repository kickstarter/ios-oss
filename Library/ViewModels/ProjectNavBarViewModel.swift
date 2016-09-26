import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectNavBarViewModelInputs {
  func categoryButtonTapped()
  func configureWith(project project: Project)
  func projectImageIsVisible(visible: Bool)
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

  // Emits two booleans that determine if the category is hidden, and if that change should be animated.
  var categoryHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var goToLoginTout: Signal<(), NoError> { get }

  /// Emits the name of the project
  var projectName: Signal<String, NoError> { get }

  /// Emits when the project has been successfully starred and a prompt should be shown to the user.
  var showProjectStarredPrompt: Signal<String, NoError> { get }

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

  // swiftlint:disable function_body_length
  public init() {
    let configuredProject = combineLatest(
      self.projectProperty.signal.ignoreNil(),
      self.viewDidLoadProperty.signal
      )
      .map(first)

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
    let userLoginAfterTappingStar = combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedStar
      )
      .ignoreValues()
      .take(1)

    let toggleStarLens = Project.lens.personalization.isStarred %~ { !($0 ?? false) }

    let projectOnStarToggle = configuredProject
      .takeWhen(.merge(loggedInUserTappedStar, userLoginAfterTappingStar))
      .scan(nil) { accum, project in (accum ?? project) |> toggleStarLens }
      .ignoreNil()

    let projectOnStarToggleAndSuccess = projectOnStarToggle
      .switchMap { project in
        AppEnvironment.current.apiService.toggleStar(project)
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .map { ($0.project, success: true) }
          .flatMapError { _ in .init(value: (project, success: false)) }
    }

    let projectOnStarToggleSuccess = projectOnStarToggleAndSuccess
      .filter(second)
      .map(first)

    let revertStarToggle = projectOnStarToggle
      .takeWhen(projectOnStarToggleAndSuccess.filter(negate • second))
      .map(toggleStarLens)

    let project = Signal
      .merge(configuredProject, projectOnStarToggle, projectOnStarToggleSuccess, revertStarToggle)

    self.categoryButtonBackgroundColor = configuredProject.map {
        discoveryGradientColors(forCategoryId: $0.category.rootId).0.colorWithAlphaComponent(0.8)
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

    self.showProjectStarredPrompt = projectOnStarToggleSuccess
      .filter { $0.personalization.isStarred == true && !$0.endsIn48Hours }
      .map { _ in Strings.project_star_confirmation() }

    self.starButtonSelected = project
      .map { $0.personalization.isStarred == true }
      .skipRepeats()

    self.starButtonAccessibilityHint = self.starButtonSelected
      .map { starred in starred ? Strings.Unstars_project() : Strings.Stars_projects() }

    self.projectName = project.map(Project.lens.name.view)

    let videoIsPlaying = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.projectVideoDidStartProperty.signal.mapConst(true),
      self.projectVideoDidFinishProperty.signal.mapConst(false)
    )



    self.categoryHiddenAndAnimate = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst((false, false)),

      combineLatest(self.projectImageIsVisibleProperty.signal, videoIsPlaying)
        .map { projectImageIsVisible, videoIsPlaying in
          (videoIsPlaying ? true : !projectImageIsVisible, true)
      }
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

    projectOnStarToggleSuccess
      .observeNext { AppEnvironment.current.koala.trackProjectStar($0) }
  }
  // swiftlint:enable function_body_length

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let projectImageIsVisibleProperty = MutableProperty(false)
  public func projectImageIsVisible(visible: Bool) {
    self.projectImageIsVisibleProperty.value = visible
  }

  private let projectVideoDidFinishProperty = MutableProperty()
  public func projectVideoDidFinish() {
    self.projectVideoDidFinishProperty.value = ()
  }

  private let projectVideoDidStartProperty = MutableProperty()
  public func projectVideoDidStart() {
    self.projectVideoDidStartProperty.value = ()
  }

  public func categoryButtonTapped() {
  }

  private let starButtonTappedProperty = MutableProperty()
  public func starButtonTapped() {
    self.starButtonTappedProperty.value = ()
  }

  private let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  private let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let backgroundOpaqueAndAnimate: Signal<(opaque: Bool, animate: Bool), NoError>
  public let categoryButtonBackgroundColor: Signal<UIColor, NoError>
  public let categoryButtonText: Signal<String, NoError>
  public let categoryButtonTintColor: Signal<UIColor, NoError>
  public let categoryButtonTitleColor: Signal<UIColor, NoError>
  public let categoryHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let projectName: Signal<String, NoError>
  public let showProjectStarredPrompt: Signal<String, NoError>
  public let starButtonAccessibilityHint: Signal<String, NoError>
  public let starButtonSelected: Signal<Bool, NoError>
  public let titleHiddenAndAnimate: Signal<(hidden: Bool, animate: Bool), NoError>

  public var inputs: ProjectNavBarViewModelInputs { return self }
  public var outputs: ProjectNavBarViewModelOutputs { return self }
}
