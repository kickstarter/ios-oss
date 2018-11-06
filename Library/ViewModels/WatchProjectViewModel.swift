import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol WatchProjectViewModelInputs {
  func awakeFromNib()
  func configure(with project: Project)
  func projectFromNotification(project: Project?)
  func saveButtonTapped(selected: Bool)
  func userSessionEnded()
  func userSessionStarted()
  func viewDidLoad()
}

public protocol WatchProjectViewModelOutputs {
  /// Emits a boolean to determine whether to create haptics
  var generateSelectionFeedback: Signal<(), NoError> { get }

  /// Emits a boolean to determine whether to create haptics
  var generateSuccessFeedback: Signal<(), NoError> { get }

  /// Emits when the login tout should be shown to the user.
  var goToLoginTout: Signal<(), NoError> { get }

  /// Emits a project.
  var postNotificationWithProject: Signal<Project, NoError> { get }

  /// Emits the accessibility hint for the star button.
  var saveButtonAccessibilityValue: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the save button is selected.
  var saveButtonSelected: Signal<Bool, NoError> { get }

  /// Emits when a contextual Push Notification dialog should be shown.
  var showNotificationDialog: Signal<Notification, NoError> { get }

  /// Emits when the project has been successfully saved and a prompt should be shown to the user.
  var showProjectSavedPrompt: Signal<Void, NoError> { get }
}

public protocol WatchProjectViewModelType {
  var inputs: WatchProjectViewModelInputs { get }
  var outputs: WatchProjectViewModelOutputs { get }
}

public final class WatchProjectViewModel: WatchProjectViewModelType,
WatchProjectViewModelInputs, WatchProjectViewModelOutputs {

  public init() {
    let viewReady = Signal.merge(self.viewDidLoadProperty.signal, self.awakeFromNibProperty.signal)

    let configuredProject = Signal.combineLatest(
      self.projectProperty.signal.skipNil(),
      viewReady
      )
      .map(first)
      .map(cached(project:))

    let currentUser = Signal.merge([
      viewReady,
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal
      ])
      .map { AppEnvironment.current.currentUser }
      .skipRepeats(==)

    let loggedInUserTappedSaveButton = currentUser
      .takePairWhen(self.saveButtonTappedProperty.signal)
      .filter { user, _ in user != nil }
      .map(second)

    let loggedOutUserTappedSaveButton = currentUser
      .takePairWhen(self.saveButtonTappedProperty.signal)
      .filter { user, _ in user == nil }
      .map(second)

    // Emits only when a user logs in after having tapped the save/heart while logged out.
    let userLoginAfterTappingSaveButton = Signal.combineLatest(
      self.userSessionStartedProperty.signal,
      loggedOutUserTappedSaveButton
    )

    let saveButtonTapped = Signal.merge(
      loggedInUserTappedSaveButton,
      userLoginAfterTappingSaveButton.map(second)
    )

    let projectOnSaveButtonToggle = configuredProject
      .takePairWhen(saveButtonTapped)

    let watchProjectToggle = projectOnSaveButtonToggle
      .map { project, selected in (project, !selected) }
      // immediately cache and return the project with the correct watch value
      .map(watchAndCacheProject(_:shouldWatch:))

    // make the mutation request to the watch/unwatch and flip the result only if the call fails
    let watchProjectResult = watchProjectToggle
      .ksr_debounce(.milliseconds(500), on: AppEnvironment.current.scheduler)
      .switchMap { project, shouldWatch in
        watchProjectProducer(with: project, shouldWatch: shouldWatch)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .map { _ in (project, project.personalization.isStarred ?? false, success: true) }
          .flatMapError { _ in .init(value: (project, !shouldWatch, success: false)) }
    }

    let projectOnSaveButtonToggleSuccess = watchProjectResult
      .filter(third)
      .map(first)

    // update the cache with the result and return it
    let projectResultUpdatingCache = watchProjectResult
      .map { project, shouldWatch, _ in (project, shouldWatch) }
      .map(watchAndCacheProject(_:shouldWatch:))

    let projectSavedFromNotification = configuredProject
      .takePairWhen(self.projectFromNotificationProperty.signal.skipNil())
      .filter { $0.id == $1.id }
      .map { $0.1 }

    // Project emits with initial configured value, immediately when watched, again on watch result
    let project = Signal.merge(
      configuredProject,
      projectSavedFromNotification,
      watchProjectToggle.map(first),
      projectResultUpdatingCache.map(first)
    )

    self.goToLoginTout = loggedOutUserTappedSaveButton.ignoreValues()

    self.showProjectSavedPrompt = project
      .takeWhen(saveButtonTapped)
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

    self.showNotificationDialog = project
      .takeWhen(saveButtonTapped)
      .filter { _ in shouldShowNotificationDialog() }
      .on(value: { _ in
        AppEnvironment.current.ubiquitousStore.hasSeenSaveProjectAlert = true
        AppEnvironment.current.userDefaults.hasSeenSaveProjectAlert = true
      })
      .ignoreValues()
      .map { _ in
        Notification(
          name: .ksr_showNotificationsDialog,
          userInfo: [UserInfoKeys.context: PushNotificationDialog.Context.save]
        )
    }

    self.saveButtonSelected = project
      .map { $0.personalization.isStarred == true }
      .skipRepeats()

    self.generateSuccessFeedback = saveButtonTapped.signal.filter(isFalse).ignoreValues()
    self.generateSelectionFeedback = saveButtonTapped.signal.filter(isTrue).ignoreValues()

    self.saveButtonAccessibilityValue = self.saveButtonSelected
      .map { starred in starred ? Strings.Saved() : Strings.Unsaved() }

    self.postNotificationWithProject = project
      .takeWhen(saveButtonTapped)

    projectOnSaveButtonToggleSuccess
      .observeValues { AppEnvironment.current.koala.trackProjectSave($0, context: .project) }
  }

  private let awakeFromNibProperty = MutableProperty(())
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configure(with project: Project) {
    self.projectProperty.value = project
  }

  fileprivate let projectFromNotificationProperty = MutableProperty<Project?>(nil)
  public func projectFromNotification(project: Project?) {
    self.projectFromNotificationProperty.value = project
  }

  fileprivate let saveButtonTappedProperty = MutableProperty(false)
  public func saveButtonTapped(selected: Bool) {
    self.saveButtonTappedProperty.value = selected
  }

  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let generateSuccessFeedback: Signal<(), NoError>
  public let generateSelectionFeedback: Signal<(), NoError>
  public let goToLoginTout: Signal<(), NoError>
  public let postNotificationWithProject: Signal<Project, NoError>
  public let saveButtonAccessibilityValue: Signal<String, NoError>
  public let saveButtonSelected: Signal<Bool, NoError>
  public let showNotificationDialog: Signal<Notification, NoError>
  public let showProjectSavedPrompt: Signal<Void, NoError>

  public var inputs: WatchProjectViewModelInputs { return self }
  public var outputs: WatchProjectViewModelOutputs { return self }

}

private func watchProjectProducer(with project: Project,
                                  shouldWatch: Bool) -> SignalProducer<Bool, GraphError> {
  guard shouldWatch else {
    return AppEnvironment.current.apiService.unwatchProject(input: UnwatchProjectInput(id: project.graphID))
      .map { $0.unwatchProject.project.isWatched }
  }

  return AppEnvironment.current.apiService.watchProject(input: WatchProjectInput(id: project.graphID))
    .map { $0.watchProject.project.isWatched }
}

private func cached(project: Project) -> Project {
  guard
    let projectCache = AppEnvironment.current.cache[KSCache.ksr_projectSaved] as? [Int: Bool],
    let isSaved = projectCache[project.id] ?? project.personalization.isStarred
    else { return project }

  return project |> Project.lens.personalization.isStarred .~ isSaved
}

private func watchAndCacheProject(_ project: Project, shouldWatch: Bool) -> (Project, Bool) {
  // create cache if it doesn't exist yet
  let tryCache = AppEnvironment.current.cache[KSCache.ksr_projectSaved]
  AppEnvironment.current.cache[KSCache.ksr_projectSaved] = tryCache ?? [Int: Bool]()

  // prepare result
  let result = (project |> Project.lens.personalization.isStarred .~ shouldWatch, shouldWatch)

  guard var cache = AppEnvironment.current.cache[KSCache.ksr_projectSaved] as? [Int: Bool] else {
    return result
  }

  // write to cache
  cache[project.id] = shouldWatch
  AppEnvironment.current.cache[KSCache.ksr_projectSaved] = cache

  return result
}

private func shouldShowNotificationDialog() -> Bool {
  return PushNotificationDialog.canShowDialog(for: .save) &&
    AppEnvironment.current.currentUser?.stats.starredProjectsCount == 0
}
