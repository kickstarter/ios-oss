import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol DiscoveryPageViewModelInputs {
  /// Call when the Config has been updated in the AppEnvironment
  func configUpdated(config: Config?)

  /// Call with the sort provided to the view.
  func configureWith(sort: DiscoveryParams.Sort)

  /// Call when the current environment has changed
  func currentEnvironmentChanged(environment: EnvironmentType)

  /// Call when the editioral cell is tapped
  func discoveryEditorialCellTapped(with tagId: DiscoveryParams.TagID)

  /// Call when onboarding has been completed
  func onboardingCompleted()

  /// Call when the personalization cell is tapped
  func personalizationCellTapped()

  /// Call when the personalization cell dismiss button is tapped
  func personalizationCellDismissTapped()

  /// Call when the user pulls tableView to refresh
  func pulledToRefresh()

  /// Call when the scrollViewDidScroll with its current contentOffset
  func scrollViewDidScroll(toContentOffset offset: CGPoint)

  /// Call when the filter is changed.
  func selectedFilter(_ params: DiscoveryParams)

  /// Call when the onboarding login/signup button is tapped
  func signupLoginButtonTapped()

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
  var activitiesForSample: Signal<[Activity], Never> { get }

  /// Hack to emit when we should asynchronously reload the table view's data to properly display postcards.
  /// Hopefully in the future we can remove this when we can resolve postcard display issues.
  var asyncReloadData: Signal<Void, Never> { get }

  /// Emits the contentInset for the UITableView
  var contentInset: Signal<UIEdgeInsets, Never> { get }

  /// Emits when the personalization cell should be deleted
  var dismissPersonalizationCell: Signal<Void, Never> { get }

  /// Emits a project and ref tag that we should go to from the activity sample.
  var goToActivityProject: Signal<(Project, RefTag), Never> { get }

  /// Emits an array of KsApi.Category objects used to generate a curated list of projects
  var goToCuratedProjects: Signal<[KsApi.Category], Never> { get }

  /// Emits a refTag for the editorial project list
  var goToEditorialProjectList: Signal<DiscoveryParams.TagID, Never> { get }

  /// Emits a LoginIntent for the LoginToutViewController ot be configured with
  var goToLoginSignup: Signal<LoginIntent, Never> { get }

  /// Emits a project, playlist, ref tag that we should go to from discovery.
  var goToProjectPlaylist: Signal<(Project, [Project], RefTag), Never> { get }

  /// Emits a project and update when should go to update.
  var goToProjectUpdate: Signal<(Project, Update), Never> { get }

  /// Emits when we should dismiss the empty state controller.
  var hideEmptyState: Signal<(), Never> { get }

  /// Emits with the current contentOffset.
  var notifyDelegateContentOffsetChanged: Signal<CGPoint, Never> { get }

  /// Emits a list of projects that should be shown, and the corresponding filter request params
  var projectsLoaded: Signal<([Project], DiscoveryParams?, OptimizelyExperiment.Variant), Never> { get }

  /// Emits a boolean that determines if projects are currently loading or not.
  var projectsAreLoadingAnimated: Signal<(Bool, Bool), Never> { get }

  /// Emits when should scroll to project with row number.
  var scrollToProjectRow: Signal<Int, Never> { get }

  /// Emits a bool to allow status bar tap to scroll the table view to the top.
  var setScrollsToTop: Signal<Bool, Never> { get }

  /// Emits to show an editorial header
  var showEditorialHeader: Signal<DiscoveryEditorialCellValue?, Never> { get }

  /// Emits to show the empty state controller.
  var showEmptyState: Signal<EmptyState, Never> { get }

  /// Emits a boolean that determines of the onboarding should be shown.
  var showOnboarding: Signal<Bool, Never> { get }

  /// Emits to show the personalization section
  var showPersonalization: Signal<Bool, Never> { get }
}

public protocol DiscoveryPageViewModelType {
  var inputs: DiscoveryPageViewModelInputs { get }
  var outputs: DiscoveryPageViewModelOutputs { get }
}

public final class DiscoveryPageViewModel: DiscoveryPageViewModelType, DiscoveryPageViewModelInputs,
  DiscoveryPageViewModelOutputs {
  public init() {
    let currentUser = Signal.merge(
      self.userSessionStartedProperty.signal,
      self.userSessionEndedProperty.signal,
      self.viewWillAppearProperty.signal
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

    let environmentChanged = self.currentEnvironmentChangedProperty.signal
      .skipNil()
      .skipRepeats()

    let firstPageParams = Signal.combineLatest(
      currentUser,
      paramsChanged,
      isVisible
    )
    .filter { _, _, visible in
      visible
    }
    .skipRepeats { lhs, rhs in
      lhs.0 == rhs.0 && lhs.1 == rhs.1
    }
    .map { $0.1 }

    let requestFirstPageWith = Signal.merge(
      firstPageParams,
      firstPageParams.takeWhen(environmentChanged),
      firstPageParams.takeWhen(self.pulledToRefreshProperty.signal)
    )

    let paginatedProjects: Signal<[Project], Never>
    let isLoading: Signal<Bool, Never>
    (paginatedProjects, isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { $0.projects },
      cursorFromEnvelope: { $0.urls.api.moreProjects },
      requestFromParams: { AppEnvironment.current.apiService.fetchDiscovery(params: $0) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchDiscovery(paginationUrl: $0) },
      concater: { ($0 + $1).distincts() }
    )

    let projects = Signal.merge(
      paginatedProjects,
      self.selectedFilterProperty.signal.skipNil().skipRepeats().mapConst([])
    )
    .skip { $0.isEmpty }
    .skipRepeats(==)

    let projectsData = paramsChanged.takePairWhen(projects)
      .map { params, projects -> ([Project], DiscoveryParams?, OptimizelyExperiment.Variant) in
        let variant = OptimizelyExperiment.nativeProjectCardsExperimentVariant()

        return (projects, params, variant)
      }

    self.projectsLoaded = projectsData

    self.asyncReloadData = self.projectsLoaded.take(first: 1).ignoreValues()

    self.contentInset = self.viewWillAppearProperty.signal
      .map { _ in
        let variant = OptimizelyExperiment.nativeProjectCardsExperimentVariant()

        switch variant {
        case .variant1:
          return .init(topBottom: Styles.grid(1))
        case .variant2, .control:
          return .zero
        }
      }

    let isRefreshing = isLoading
      .combineLatest(with: self.pulledToRefreshProperty.signal)
      .map(first)
      .skipRepeats()

    let projectsLoadingNoRefresh = Signal.merge(
      isLoading,
      isLoading.takeWhen(isRefreshing).mapConst(false)
    ).skipRepeats()

    self.projectsAreLoadingAnimated = Signal.merge(
      isRefreshing.map { ($0, true) },
      projectsLoadingNoRefresh.map { ($0, false) },
      self.viewWillAppearProperty.signal.take(first: 1).mapConst((true, false))
    )
    .skipRepeats(==)

    self.showEmptyState = Signal.combineLatest(
      paramsChanged,
      self.projectsAreLoadingAnimated.map(first),
      paginatedProjects
    )
    .filter { _, projectsAreLoading, projects in projectsAreLoading == false && projects.isEmpty }
    .map { params, _, _ in
      emptyState(forParams: params)
    }
    .skipNil()
    .skipRepeats()

    self.hideEmptyState = Signal.merge(
      self.viewWillAppearProperty.signal.take(first: 1),
      self.asyncReloadData,
      paginatedProjects.filter { !$0.isEmpty }.ignoreValues(),
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
      .map { params, project in (project, RefTag.fromParams(params)) }

    self.goToActivityProject = activitySampleTapped

    self.goToProjectPlaylist = projects
      .takePairWhen(projectCardTapped)
      .map(unpack)
      .map { projects, project, refTag in (project, projects, refTag) }

    self.goToProjectUpdate = self.tappedActivity.signal.skipNil()
      .filter { $0.category == .update }
      .flatMap { activity -> SignalProducer<(Project, Update), Never> in
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

    self.showOnboarding = Signal.combineLatest(currentUser, paramsChanged)
      .map { user, params in user == nil && params.sort == .magic && params.tagId == nil }
      .skipRepeats()

    self.scrollToProjectRow = self.transitionedToProjectRowAndTotalProperty.signal.skipNil().map(first)

    self.setScrollsToTop = Signal.merge(
      self.viewDidAppearProperty.signal.mapConst(true),
      self.viewDidDisappearProperty.signal.mapConst(false)
    )

    // MARK: - Editorial Header

    let filtersUpdated = self.sortProperty.signal.skipNil()
      .takePairWhen(self.selectedFilterProperty.signal.skipNil().skipRepeats())

    let editorialHeaderShouldShow = filtersUpdated
      .filterMap { sort, filterParams -> Bool? in
        if sort != .magic {
          return nil
        }

        return sort == .magic && filterParams == DiscoveryViewModel.initialParams()
      }

    let featureFlagValue = self.sortProperty.signal.skipNil()
      .map { _ in editorialLightsOnFeatureIsEnabled() }

    let updateEditorialHeader = Signal.combineLatest(editorialHeaderShouldShow, featureFlagValue)

    self.showEditorialHeader = updateEditorialHeader
      .map { shouldShow, isEnabled in
        guard shouldShow, isEnabled else {
          return nil
        }

        return DiscoveryEditorialCellValue(
          title: Strings.Introducing_Lights_On(),
          subtitle: Strings.Support_creative_spaces_and_businesses_affected_by(),
          imageName: "lights-on", tagId: .lightsOn
        )
      }.skipRepeats()

    // MARK: Personalization Callout Card

    let viewReady = Signal.combineLatest(
      self.viewDidAppearProperty.signal,
      editorialHeaderShouldShow
    )

    self.showPersonalization = Signal.merge(
      viewReady,
      viewReady.takeWhen(self.onboardingCompletedProperty.signal)
    )
    .map(second)
    .map { shouldShowHeader in
      shouldShowHeader && shouldShowPersonalization()
    }

    self.goToCuratedProjects = self.personalizationCellTappedProperty.signal
      .map(cachedCategories)
      .skipNil()

    self.dismissPersonalizationCell = self.personalizationCellDismissTappedProperty.signal
      .on { _ in
        AppEnvironment.current.userDefaults.hasDismissedPersonalizationCard = true
      }

    self.goToEditorialProjectList = self.discoveryEditorialCellTappedWithValueProperty.signal
      .skipNil()

    self.notifyDelegateContentOffsetChanged = Signal.combineLatest(
      self.scrollViewDidScrollToContentOffsetProperty.signal.skipNil(),
      self.projectsAreLoadingAnimated.map(first)
    )
    .filter(second >>> isFalse)
    .map(first)

    self.goToLoginSignup = self.signupLoginButtonTappedProperty.signal
      .mapConst(LoginIntent.discoveryOnboarding)

    // MARK: - Tracking

    requestFirstPageWith
      .observeValues { params in
        let optimizelyProps = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala.trackDiscovery(
          params: params,
          optimizelyProperties: optimizelyProps
        )
      }

    let personalizationCellTappedAndRefTag = self.personalizationCellTappedProperty.signal
      .mapConst(RefTag.onboarding)

    self.personalizationCellTappedProperty.signal
      .observeValues { _ in
        AppEnvironment.current.optimizelyClient?.track(eventName: "Editorial Card Clicked")
      }

    let editorialCellTappedAndRefTag = self.discoveryEditorialCellTappedWithValueProperty.signal
      .skipNil()
      .map { RefTag.projectCollection($0) }

    let editorialOrPersonaliztionCardTappedAndRefTag = Signal.merge(
      personalizationCellTappedAndRefTag,
      editorialCellTappedAndRefTag
    )

    requestFirstPageWith
      .takePairWhen(editorialOrPersonaliztionCardTappedAndRefTag)
      .observeValues { params, refTag in
        let optimizelyProps = refTag == .onboarding ? optimizelyProperties() : nil

        AppEnvironment.current.koala.trackEditorialHeaderTapped(
          params: params,
          refTag: refTag,
          optimizelyProperties: optimizelyProps ?? [:]
        )
      }

    paramsChanged
      .takePairWhen(self.tappedProject.signal.skipNil())
      .observeValues { params, project in
        let optyProperties = optimizelyProperties() ?? [:]

        AppEnvironment.current.koala.trackProjectCardClicked(
          project: project,
          params: params,
          location: .discovery,
          optimizelyProperties: optyProperties
        )

        AppEnvironment.current.optimizelyClient?.track(eventName: "Project Card Clicked")
      }

    self.goToLoginSignup
      .observeValues { AppEnvironment.current.koala.trackLoginOrSignupButtonClicked(intent: $0) }
  }

  fileprivate let configUpdatedProperty = MutableProperty<Config?>(nil)
  public func configUpdated(config: Config?) {
    self.configUpdatedProperty.value = config
  }

  fileprivate let currentEnvironmentChangedProperty = MutableProperty<EnvironmentType?>(nil)
  public func currentEnvironmentChanged(environment: EnvironmentType) {
    self.currentEnvironmentChangedProperty.value = environment
  }

  fileprivate let discoveryEditorialCellTappedWithValueProperty
    = MutableProperty<DiscoveryParams.TagID?>(nil)
  public func discoveryEditorialCellTapped(with tagId: DiscoveryParams.TagID) {
    self.discoveryEditorialCellTappedWithValueProperty.value = tagId
  }

  fileprivate let onboardingCompletedProperty = MutableProperty(())
  public func onboardingCompleted() {
    self.onboardingCompletedProperty.value = ()
  }

  fileprivate let personalizationCellTappedProperty = MutableProperty(())
  public func personalizationCellTapped() {
    self.personalizationCellTappedProperty.value = ()
  }

  fileprivate let personalizationCellDismissTappedProperty = MutableProperty(())
  public func personalizationCellDismissTapped() {
    self.personalizationCellDismissTappedProperty.value = ()
  }

  fileprivate let pulledToRefreshProperty = MutableProperty(())
  public func pulledToRefresh() {
    self.pulledToRefreshProperty.value = ()
  }

  fileprivate let sortProperty = MutableProperty<DiscoveryParams.Sort?>(nil)
  public func configureWith(sort: DiscoveryParams.Sort) {
    self.sortProperty.value = sort
  }

  private let scrollViewDidScrollToContentOffsetProperty = MutableProperty<CGPoint?>(nil)
  public func scrollViewDidScroll(toContentOffset offset: CGPoint) {
    self.scrollViewDidScrollToContentOffsetProperty.value = offset
  }

  fileprivate let selectedFilterProperty = MutableProperty<DiscoveryParams?>(nil)
  public func selectedFilter(_ params: DiscoveryParams) {
    self.selectedFilterProperty.value = params
  }

  fileprivate let signupLoginButtonTappedProperty = MutableProperty(())
  public func signupLoginButtonTapped() {
    self.signupLoginButtonTappedProperty.value = ()
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

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  fileprivate let viewDidDisappearProperty = MutableProperty(false)
  public func viewDidDisappear(animated: Bool) {
    self.viewDidDisappearProperty.value = animated
  }

  fileprivate let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let activitiesForSample: Signal<[Activity], Never>
  public let asyncReloadData: Signal<Void, Never>
  public let contentInset: Signal<UIEdgeInsets, Never>
  public let dismissPersonalizationCell: Signal<Void, Never>
  public let goToActivityProject: Signal<(Project, RefTag), Never>
  public let goToCuratedProjects: Signal<[KsApi.Category], Never>
  public let goToEditorialProjectList: Signal<DiscoveryParams.TagID, Never>
  public let goToLoginSignup: Signal<LoginIntent, Never>
  public let goToProjectPlaylist: Signal<(Project, [Project], RefTag), Never>
  public let goToProjectUpdate: Signal<(Project, Update), Never>
  public let hideEmptyState: Signal<Void, Never>
  public let notifyDelegateContentOffsetChanged: Signal<CGPoint, Never>
  public let projectsLoaded: Signal<([Project], DiscoveryParams?, OptimizelyExperiment.Variant), Never>
  public let projectsAreLoadingAnimated: Signal<(Bool, Bool), Never>
  public let setScrollsToTop: Signal<Bool, Never>
  public let scrollToProjectRow: Signal<Int, Never>
  public let showEditorialHeader: Signal<DiscoveryEditorialCellValue?, Never>
  public let showEmptyState: Signal<EmptyState, Never>
  public let showOnboarding: Signal<Bool, Never>
  public let showPersonalization: Signal<Bool, Never>

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

private func shouldShowPersonalization() -> Bool {
  guard AppEnvironment.current.userDefaults.hasCompletedCategoryPersonalizationFlow,
    !AppEnvironment.current.userDefaults.hasDismissedPersonalizationCard else {
    return false
  }

  guard let variant = AppEnvironment.current.optimizelyClient?
    .getVariation(for: OptimizelyExperiment.Key.onboardingCategoryPersonalizationFlow.rawValue) else {
    return false
  }

  switch variant {
  case .control, .variant2:
    return false
  case .variant1:
    return true
  }
}

private func cachedCategories() -> [KsApi.Category]? {
  guard let data = AppEnvironment.current.userDefaults.onboardingCategories,
    let categories = try? JSONDecoder().decode([KsApi.Category].self, from: data)
  else {
    return []
  }

  return categories
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

private func editorialLightsOnFeatureIsEnabled() -> Bool {
  return AppEnvironment.current.optimizelyClient?
    .isFeatureEnabled(featureKey: OptimizelyFeature.Key.lightsOn.rawValue) ?? false
}
