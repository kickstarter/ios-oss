import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol DiscoveryPageViewModelInputs {
  /// Call with the sort provided to the view.
  func configureWith(sort: DiscoveryParams.Sort)

  /// Call when the filter is changed.
  func selectedFilter(_ params: DiscoveryParams)

  /// Call when the user taps on the activity sample.
  func tapped(activity: Activity)

  /// Call when the user taps on a project.
  func tapped(project: Project)

  /// Call when the project navigator has transitioned to a new project with its index.
  func transitionedToProject(at row: Int, outOf totalRows: Int)

  /// Call when the controller has received a user session ended notification.
  func userSessionEnded()

  /// Call when the controller has received a user session started notification.
  func userSessionStarted()

  /// Call when the view appears.
  func viewDidAppear()

  /// Call when the view disappears.
  func viewDidDisappear(animated: Bool)

  /// Call when the view will appear.
  func viewWillAppear()

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol DiscoveryPageViewModelOutputs {
  /// Emits a list of activities to be displayed in the sample.
  var activitiesForSample: Signal<[Activity], NoError> { get }

  /// Hack to emit when we should asynchronously reload the table view's data to properly display postcards.
  /// Hopefully in the future we can remove this when we can resolve postcard display issues.
  var asyncReloadData: Signal<Void, NoError> { get }

  /// Emits when we should dismiss the empty state controller.
  var hideEmptyState: Signal<(), NoError> { get }

  /// Emits a project and ref tag that we should go to from the activity sample.
  var goToActivityProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits a project, playlist, ref tag that we should go to from discovery.
  var goToProjectPlaylist: Signal<(Project, [Project], RefTag), NoError> { get }

  /// Emits a project and update when should go to update.
  var goToProjectUpdate: Signal<(Project, Update), NoError> { get }

  /// Emits when the login tout should be shown to the user.
 // var goToLoginTout: Signal<(), NoError> { get }

  /// Emits a list of projects that should be shown.
  var projects: Signal<[Project], NoError> { get }

  /// Emits a boolean that determines if projects are currently loading or not.
  var projectsAreLoading: Signal<Bool, NoError> { get }

  /// Emits when should scroll to project with row number.
  var scrollToProjectRow: Signal<Int, NoError> { get }

  /// Emits a bool to allow status bar tap to scroll the table view to the top.
  var setScrollsToTop: Signal<Bool, NoError> { get }

  /// Emits to show the empty state controller.
  var showEmptyState: Signal<EmptyState, NoError> { get }

  /// Emits a boolean that determines of the onboarding should be shown.
  var showOnboarding: Signal<Bool, NoError> { get }
}

public protocol DiscoveryPageViewModelType {
  var inputs: DiscoveryPageViewModelInputs { get }
  var outputs: DiscoveryPageViewModelOutputs { get }
}

public final class DiscoveryPageViewModel: DiscoveryPageViewModelType, DiscoveryPageViewModelInputs,
  DiscoveryPageViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let currentUser = Signal.merge(
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal,
      self.viewDidAppearProperty.signal
    )
      .map { AppEnvironment.current.currentUser }
      .skipRepeats(==)

    let paramsChanged = Signal.combineLatest(
      self.sortProperty.signal.skipNil(),
      self.selectedFilterProperty.signal.skipNil()
      )
      .map(DiscoveryParams.lens.sort.set)

    let isCloseToBottom = Signal.merge(
      self.willDisplayRowProperty.signal.skipNil(),
      self.transitionedToProjectRowAndTotalProperty.signal.skipNil()
      )
      .map { row, total in
        row >= total - 3 && row > 0
      }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let isVisible = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(true),
      self.viewDidDisappearProperty.signal.mapConst(false)
      ).skipRepeats()

    let requestFirstPageWith = Signal.combineLatest(currentUser, paramsChanged, isVisible)
      .filter { _, _, visible in visible }
      .skipRepeats { lhs, rhs in lhs.0 == rhs.0 && lhs.1 == rhs.1 }
      .map(second)

    let paginatedProjects: Signal<[Project], NoError>
    let pageCount: Signal<Int, NoError>
    (paginatedProjects, self.projectsAreLoading, pageCount) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) },
      concater: { ($0 + $1).distincts() })

    self.projects = Signal.merge(
      paginatedProjects,
      self.selectedFilterProperty.signal.skipNil().skipRepeats().mapConst([])
      )
      .skip { $0.isEmpty }
      .skipRepeats(==)

    self.asyncReloadData = self.projects.take(first: 1).ignoreValues()

    self.showEmptyState = paramsChanged
      .takeWhen(paginatedProjects.filter { $0.isEmpty })
      .map(emptyState(forParams:))
      .skipNil()

    self.hideEmptyState = Signal.merge(
      self.viewWillAppearProperty.signal.take(first: 1),
      paramsChanged.skip(first: 1).ignoreValues()
    )

    let fetchActivityEvent = self.viewDidAppearProperty.signal
      .filter { _ in AppEnvironment.current.currentUser != nil }
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchActivities(count: 1)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    let activitySampleTapped = self.tappedActivity.signal.skipNil()
      .filter { $0.category != .update }
      .map { $0.project }
      .skipNil()
      .map { ($0, RefTag.activitySample) }

    let projectCardTapped = paramsChanged
      .takePairWhen(self.tappedProject.signal.skipNil())
      .map { params, project in (project, refTag(fromParams: params, project: project)) }

    self.goToActivityProject = activitySampleTapped

    self.goToProjectPlaylist = self.projects
      .takePairWhen(projectCardTapped)
      .map(unpack)
      .map { projects, project, refTag in (project, projects, refTag) }

    self.goToProjectUpdate = self.tappedActivity.signal.skipNil()
      .filter { $0.category == .update }
      .flatMap { activity -> SignalProducer<(Project, Update), NoError> in
        guard let project = activity.project, let update = activity.update else {
          return .empty
        }
        return SignalProducer(value: (project, update))
    }

    let activities = fetchActivityEvent.values()
      .map { $0.activities }
      .skipRepeats(==)
      .map { $0.filter { activity in hasNotSeen(activity: activity) } }
      .on(value: { activities in saveSeen(activities: activities) })

    let clearActivitySampleOnLogout = self.viewWillAppearProperty.signal
      .filter { _ in AppEnvironment.current.currentUser == nil }

    let clearActivitySampleOnNavigate = Signal.merge(
      paramsChanged.mapConst(true),
      self.goToActivityProject.mapConst(false),
      self.goToProjectUpdate.mapConst(false),
      self.viewDidDisappearProperty.signal.filter(isFalse),
      self.viewDidAppearProperty.signal.mapConst(true)
      )
      .takeWhen(self.viewDidDisappearProperty.signal)
      .filter(isTrue)

    self.activitiesForSample = Signal.merge(
      activities,
      clearActivitySampleOnLogout.mapConst([]),
      clearActivitySampleOnNavigate.mapConst([])
      )
      .skipRepeats(==)

    self.showOnboarding = Signal.combineLatest(currentUser, self.sortProperty.signal.skipNil())
      .map { $0 == nil && $1 == .magic }
      .skipRepeats()

    self.scrollToProjectRow = self.transitionedToProjectRowAndTotalProperty.signal.skipNil().map(first)

    requestFirstPageWith
      .takePairWhen(pageCount)
      .observeValues { params, page in
        AppEnvironment.current.koala.trackDiscovery(params: params, page: page)
    }

    self.setScrollsToTop = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(true),
      self.viewDidDisappearProperty.signal.mapConst(false)
    )
  }
  // swiftlint:enable function_body_length

  fileprivate let sortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func configureWith(sort: DiscoveryParams.Sort) {
    self.sortProperty.value = sort
  }
  fileprivate let selectedFilterProperty = MutableProperty<DiscoveryParams?>(nil)
  public func selectedFilter(_ params: DiscoveryParams) {
    self.selectedFilterProperty.value = params
  }
  fileprivate let tappedActivity = MutableProperty<Activity?>(nil)
  public func tapped(activity: Activity) {
    self.tappedActivity.value = activity
  }
  fileprivate let tappedProject = MutableProperty<Project?>(nil)
  public func tapped(project: Project) {
    self.tappedProject.value = project
  }
  private let transitionedToProjectRowAndTotalProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func transitionedToProject(at row: Int, outOf totalRows: Int) {
    self.transitionedToProjectRowAndTotalProperty.value = (row, totalRows)
  }
  fileprivate let userSessionStartedProperty = MutableProperty()
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }
  fileprivate let userSessionEndedProperty = MutableProperty()
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }
  fileprivate let viewDidAppearProperty = MutableProperty()
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }
  fileprivate let viewDidDisappearProperty = MutableProperty(false)
  public func viewDidDisappear(animated: Bool) {
    self.viewDidDisappearProperty.value = animated
  }
  fileprivate let viewWillAppearProperty = MutableProperty()
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }
  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let activitiesForSample: Signal<[Activity], NoError>
  public var asyncReloadData: Signal<Void, NoError>
  public let hideEmptyState: Signal<(), NoError>
  public var goToActivityProject: Signal<(Project, RefTag), NoError>
  public let goToProjectPlaylist: Signal<(Project, [Project], RefTag), NoError>
  public let goToProjectUpdate: Signal<(Project, Update), NoError>
  public let projects: Signal<[Project], NoError>
  public let projectsAreLoading: Signal<Bool, NoError>
  public let setScrollsToTop: Signal<Bool, NoError>
  public let scrollToProjectRow: Signal<Int, NoError>
  public let showEmptyState: Signal<EmptyState, NoError>
  public let showOnboarding: Signal<Bool, NoError>

  public var inputs: DiscoveryPageViewModelInputs { return self }
  public var outputs: DiscoveryPageViewModelOutputs { return self }
}

private func hasNotSeen(activity: Activity) -> Bool {
  return activity.id != AppEnvironment.current.userDefaults.lastSeenActivitySampleId
}

private func saveSeen(activities: [Activity]) {
  activities.forEach { activity in
    AppEnvironment.current.userDefaults.lastSeenActivitySampleId = activity.id
  }
}

private func refTag(fromParams params: DiscoveryParams, project: Project) -> RefTag {

  if project.isPotdToday(today: AppEnvironment.current.dateType.init().date) {
    return .discoveryPotd
  } else if params.category != nil {
    return .categoryWithSort(params.sort ?? .magic)
  } else if params.recommended == .some(true) {
    return .recsWithSort(params.sort ?? .magic)
  } else if params.staffPicks == .some(true) {
    return .recommendedWithSort(params.sort ?? .magic)
  } else if params.social == .some(true) {
    return .socialWithSort(params.sort ?? .magic)
  } else if params.starred == .some(true) {
    return .starredWithSort(params.sort ?? .magic)
  }
  return RefTag.discoveryWithSort(params.sort ?? .magic)
}

private func emptyState(forParams params: DiscoveryParams) -> EmptyState? {
  if params.starred == .some(true) {
    return .starred
  } else if params.recommended == .some(true) {
    return .recommended
  } else if params.social == .some(true) {
    return AppEnvironment.current.currentUser?.social == .some(true) ? .socialNoPledges : .socialDisabled
  }

  return nil
}
