import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ActitiviesViewModelInputs {
  /// Called when the project image in an update activity cell is tapped.
  func activityUpdateCellTappedProjectImage(activity: Activity)

  /// Call when the controller has received a user updated notification.
  func currentUserUpdated()

  /// Called when the user tapped to fix an errored pledge.
  func erroredBackingViewDidTapManage(with backing: GraphBacking)

  /// Call when the Find Friends section is dismissed.
  func findFriendsHeaderCellDismissHeader()

  /// Call when controller should transition to Friends view.
  func findFriendsHeaderCellGoToFriends()

  /// Call when user updates to be Facebook Connected.
  func findFriendsFacebookConnectCellDidFacebookConnectUser()

  /// Call when the Facebook Connect section is dismissed.
  func findFriendsFacebookConnectCellDidDismissHeader()

  /// Call when an alert should be shown.
  func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError)

  /// Call when the ManagePledgeViewController made changes.
  func managePledgeViewControllerDidFinish()

  /// Call when the feed should be refreshed, e.g. pull-to-refresh.
  func refresh()

  /// Call when the SurveyResponseViewController has been dismissed.
  func surveyResponseViewControllerDismissed()

  /// Call when an activity is tapped.
  func tappedActivity(_ activity: Activity)

  /// Call when the respond button is tapped in a survey cell.
  func tappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse)

  /// Call when a user session ends.
  func userSessionEnded()

  /// Call when a user session has started.
  func userSessionStarted()

  /// Call when the view did load.
  func viewDidLoad()

  /// Call when the view will appear with animated property.
  func viewWillAppear(animated: Bool)

  /**
   Call from the controller's `tableView:willDisplayCell:forRowAtIndexPath` method.

   - parameter row:       The 0-based index of the row displaying.
   - parameter totalRows: The total number of rows in the table view.
   */
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol ActivitiesViewModelOutputs {
  /// Emits an array of activities that should be displayed.
  var activities: Signal<[Activity], Never> { get }

  /// Emits when the tab bar item's badge value should be cleared.
  var clearBadgeValue: Signal<(), Never> { get }

  /// Emits when should remove Facebook Connect section
  var deleteFacebookConnectSection: Signal<(), Never> { get }

  /// Emits when should remove Find Friends section.
  var deleteFindFriendsSection: Signal<(), Never> { get }

  /// Emits an array of errored backings to be displayed on the top of the list of projects.
  var erroredBackings: Signal<[GraphBacking], Never> { get }

  /// Emits when we should dismiss the empty state controller.
  var hideEmptyState: Signal<(), Never> { get }

  /// Emits when should transition to Friends view with source (.Activity).
  var goToFriends: Signal<FriendsSource, Never> { get }

  /// Emits a project and backing Param to navigate to ManagePledgeViewController.
  var goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never> { get }

  /// Emits a project and ref tag that should be used to present a project controller.
  var goToProject: Signal<(Project, RefTag), Never> { get }

  /// Emits a survey response when we should navigate to the survey to fill it out.
  var goToSurveyResponse: Signal<SurveyResponse, Never> { get }

  /// Emits a project and update when we should navigate to that update.
  var goToUpdate: Signal<(Project, Update), Never> { get }

  /// Emits a boolean that indicates if the activities are refreshing.
  var isRefreshing: Signal<Bool, Never> { get }

  /// Emits `true` when logged-in, `false` when logged-out, when we should show the empty state controller.
  var showEmptyStateIsLoggedIn: Signal<Bool, Never> { get }

  /// Emits an AlertError to be displayed.
  var showFacebookConnectErrorAlert: Signal<AlertError, Never> { get }

  /// Emits whether Facebook Connect header cell should show with the .Activity source.
  var showFacebookConnectSection: Signal<(FriendsSource, Bool), Never> { get }

  /// Emits whether Find Friends header cell should show with the .Activity source.
  var showFindFriendsSection: Signal<(FriendsSource, Bool), Never> { get }

  /// Emits a non-`nil` survey response if there is an unanswered one available, and `nil` otherwise.
  var unansweredSurveys: Signal<[SurveyResponse], Never> { get }

  /// Emits a User that can be used to replace the current user in the environment.
  var updateUserInEnvironment: Signal<User, Never> { get }
}

public protocol ActivitiesViewModelType {
  var inputs: ActitiviesViewModelInputs { get }
  var outputs: ActivitiesViewModelOutputs { get }
}

public final class ActivitiesViewModel: ActivitiesViewModelType, ActitiviesViewModelInputs,
  ActivitiesViewModelOutputs {
  public init() {
    let isCloseToBottom = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in total > 3 && row >= total - 2 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let requestFirstPage = Signal
      .merge(
        self.userSessionStartedProperty.signal,
        self.viewWillAppearProperty.signal.skipNil().filter(isTrue).ignoreValues(),
        self.refreshProperty.signal
      )
      .filter { AppEnvironment.current.currentUser != nil }

    let (paginatedActivities, isLoading, pageCount) = paginate(
      requestFirstPageWith: requestFirstPage,
      requestNextPageWhen: isCloseToBottom,
      clearOnNewRequest: false,
      skipRepeats: false,
      valuesFromEnvelope: { $0.activities },
      cursorFromEnvelope: { $0.urls.api.moreActivities },
      requestFromParams: { _ in AppEnvironment.current.apiService.fetchActivities(count: nil) },
      requestFromCursor: { AppEnvironment.current.apiService.fetchActivities(paginationUrl: $0) }
    )

    let activities = paginatedActivities
      .scan([Activity]()) { acc, next in
        !next.isEmpty
          ? (acc + next).distincts().sorted { $0.id > $1.id }
          : next
      }

    self.isRefreshing = isLoading

    let clearedActivitiesOnSessionEnd = self.userSessionEndedProperty.signal.mapConst([Activity]())

    let activityToUpdate: Signal<Activity?, Never> = self.viewWillAppearProperty.signal.skipNil()
      .take(first: 1).mapConst(nil)

    let updatedActivities = Signal.combineLatest(activities, activityToUpdate)
      .map { currentActivities, updatedActivity in
        currentActivities
          .map { activity in
            activity == updatedActivity ? updatedActivity : activity
          }
          .compact()
      }

    self.activities = Signal.merge(clearedActivitiesOnSessionEnd, updatedActivities)
    self.clearBadgeValue = Signal.zip(
      self.refreshProperty.signal,
      updatedActivities.skip(first: 1)
    )
    .ignoreValues()

    let userClearingBadgeCountEvent = self.clearBadgeValue
      .filter { _ in AppEnvironment.current.currentUser != nil }
      .switchMap { _ in
        updatedUserWithClearedActivityCountProducer()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let refreshUserEvent = self.managePledgeViewControllerDidFinishProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchUserSelf()
          .materialize()
      }

    self.updateUserInEnvironment = Signal.merge(
      userClearingBadgeCountEvent.values(),
      refreshUserEvent.values()
    )

    let currentUser = Signal
      .merge(
        self.currentUserUpdatedProperty.signal.ignoreValues(),
        self.viewDidLoadProperty.signal,
        self.userSessionStartedProperty.signal,
        self.userSessionEndedProperty.signal
      )
      .map { AppEnvironment.current.currentUser }

    let erroredBackingsEvent = currentUser
      .skipNil()
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchGraphUserBackings(
          query: UserQueries.backings(GraphBacking.Status.errored.rawValue).query
        )
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .map { envelope in
          envelope.me.backings.nodes
        }
        .materialize()
      }

    self.erroredBackings = erroredBackingsEvent.values()

    let loggedInForEmptyState = self.activities
      .filter { AppEnvironment.current.currentUser != nil && $0.isEmpty }
      .skipRepeats(==)
      .mapConst(true)

    let loggedOutForEmptyState = currentUser
      .takeWhen(self.viewWillAppearProperty.signal.skipNil())
      .skipRepeats(==)
      .filter(isNil)
      .mapConst(false)

    self.showEmptyStateIsLoggedIn = Signal.merge(
      loggedInForEmptyState,
      loggedOutForEmptyState
    )

    self.hideEmptyState = Signal.merge(
      self.viewDidLoadProperty.signal.ignoreValues(),
      self.activities
        .combinePrevious([])
        .filter { previousActivities, currentActivities in
          previousActivities.isEmpty
            && !currentActivities.isEmpty
            && AppEnvironment.current.currentUser != nil
        }.ignoreValues()
    )

    let projectActivities = self.tappedActivityProperty.signal.skipNil()
      .filter { $0.category != .update }

    self.goToProject = Signal
      .merge(
        self.tappedActivityProjectImage.signal.map { $0?.project },
        projectActivities.map { $0.project }
      )
      .skipNil()
      .map { ($0, .activity) }

    let surveyEvents = currentUser
      .takeWhen(Signal.merge(
        self.viewWillAppearProperty.signal.skipNil().filter(isFalse).ignoreValues(),
        self.surveyResponseViewControllerDismissedProperty.signal
      )
      )
      .filter { $0 != nil }
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchUnansweredSurveyResponses()
          .materialize()
      }

    self.unansweredSurveys = surveyEvents.values()

    let surveyValuesOrErrors = Signal.merge(
      surveyEvents.values().ignoreValues(),
      surveyEvents.errors().ignoreValues()
    )

    self.showFindFriendsSection = surveyValuesOrErrors
      .map {
        (
          .activity,
          !FindFriendsFacebookConnectCellViewModel
            .showFacebookConnectionSection(for: AppEnvironment.current.currentUser)
            && !AppEnvironment.current.userDefaults.hasClosedFindFriendsInActivity
        )
      }

    self.showFacebookConnectSection = surveyValuesOrErrors
      .map {
        (
          .activity,
          FindFriendsFacebookConnectCellViewModel
            .showFacebookConnectionSection(for: AppEnvironment.current.currentUser) &&
            !AppEnvironment.current.userDefaults.hasClosedFacebookConnectInActivity
        )
      }

    self.deleteFacebookConnectSection = self.dismissFacebookConnectSectionProperty.signal

    self.showFacebookConnectErrorAlert = self.showFacebookConnectErrorAlertProperty.signal.skipNil()

    self.deleteFindFriendsSection = self.dismissFindFriendsSectionProperty.signal

    self.goToFriends = Signal.merge(
      self.goToFriendsProperty.signal,
      self.userFacebookConnectedProperty.signal
    )
    .mapConst(.activity)

    self.dismissFacebookConnectSectionProperty.signal
      .observeValues { AppEnvironment.current.userDefaults.hasClosedFacebookConnectInActivity = true }

    self.dismissFindFriendsSectionProperty.signal
      .observeValues { AppEnvironment.current.userDefaults.hasClosedFindFriendsInActivity = true }

    self.goToSurveyResponse = self.tappedSurveyResponseProperty.signal.skipNil()

    self.goToUpdate = self.tappedActivityProperty.signal.skipNil()
      .filter { $0.category == .update }
      .map { ($0.project, $0.update) }
      .flatMap { (project, update) -> SignalProducer<(Project, Update), Never> in
        guard let project = project, let update = update else { return .empty }
        return SignalProducer(value: (project, update))
      }

    let goToManagePledgeWithBacking = self.erroredBackingViewDidTapManageWithBackingProperty.signal
      .skipNil()

    self.goToManagePledge = goToManagePledgeWithBacking
      .map { backing -> ManagePledgeViewParamConfigData? in
        guard let pid = backing.project?.pid, let backingId = decompose(id: backing.id) else { return nil }

        return (projectParam: Param.id(pid), backingParam: Param.id(backingId))
      }
      .skipNil()

    self.activities.takePairWhen(goToManagePledgeWithBacking)
      .observeValues { activities, backing in
        let activity = activities.first { $0.project?.id == backing.project?.pid }

        guard let project = activity?.project else { return }

        AppEnvironment.current.koala.trackActivitiesManagePledgeButtonClicked(project: project)
      }

    Signal.zip(pageCount, paginatedActivities)
      .filter { pageCount, _ in
        pageCount == 1
      } // Track first page only
      .map(second)
      .map { $0.count }
      .observeValues { AppEnvironment.current.koala.trackActivities(count: $0) }
  }

  fileprivate let currentUserUpdatedProperty = MutableProperty(())
  public func currentUserUpdated() {
    self.currentUserUpdatedProperty.value = ()
  }

  fileprivate let dismissFacebookConnectSectionProperty = MutableProperty(())
  public func findFriendsFacebookConnectCellDidDismissHeader() {
    self.dismissFacebookConnectSectionProperty.value = ()
  }

  fileprivate let dismissFindFriendsSectionProperty = MutableProperty(())
  public func findFriendsHeaderCellDismissHeader() {
    self.dismissFindFriendsSectionProperty.value = ()
  }

  fileprivate let erroredBackingViewDidTapManageWithBackingProperty = MutableProperty<GraphBacking?>(nil)
  public func erroredBackingViewDidTapManage(with backing: GraphBacking) {
    self.erroredBackingViewDidTapManageWithBackingProperty.value = backing
  }

  fileprivate let managePledgeViewControllerDidFinishProperty = MutableProperty(())
  public func managePledgeViewControllerDidFinish() {
    self.managePledgeViewControllerDidFinishProperty.value = ()
  }

  fileprivate let goToFriendsProperty = MutableProperty(())
  public func findFriendsHeaderCellGoToFriends() {
    self.goToFriendsProperty.value = ()
  }

  fileprivate let showFacebookConnectErrorAlertProperty = MutableProperty<AlertError?>(nil)
  public func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError) {
    self.showFacebookConnectErrorAlertProperty.value = alert
  }

  fileprivate let viewWillAppearProperty = MutableProperty<Bool?>(nil)
  public func viewWillAppear(animated: Bool) {
    self.viewWillAppearProperty.value = animated
  }

  fileprivate let refreshProperty = MutableProperty(())
  public func refresh() {
    self.refreshProperty.value = ()
  }

  fileprivate let surveyResponseViewControllerDismissedProperty = MutableProperty(())
  public func surveyResponseViewControllerDismissed() {
    self.surveyResponseViewControllerDismissedProperty.value = ()
  }

  fileprivate let tappedActivityProjectImage = MutableProperty<Activity?>(nil)
  public func activityUpdateCellTappedProjectImage(activity: Activity) {
    self.tappedActivityProjectImage.value = activity
  }

  fileprivate let tappedSurveyResponseProperty = MutableProperty<SurveyResponse?>(nil)
  public func tappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse) {
    self.tappedSurveyResponseProperty.value = surveyResponse
  }

  fileprivate let tappedActivityProperty = MutableProperty<Activity?>(nil)
  public func tappedActivity(_ activity: Activity) {
    self.tappedActivityProperty.value = activity
  }

  fileprivate let userFacebookConnectedProperty = MutableProperty(())
  public func findFriendsFacebookConnectCellDidFacebookConnectUser() {
    self.userFacebookConnectedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let userSessionEndedProperty = MutableProperty(())
  public func userSessionEnded() {
    self.userSessionEndedProperty.value = ()
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let activities: Signal<[Activity], Never>
  public let clearBadgeValue: Signal<(), Never>
  public let deleteFacebookConnectSection: Signal<(), Never>
  public let deleteFindFriendsSection: Signal<(), Never>
  public let erroredBackings: Signal<[GraphBacking], Never>
  public let hideEmptyState: Signal<(), Never>
  public let isRefreshing: Signal<Bool, Never>
  public let goToFriends: Signal<FriendsSource, Never>
  public let goToManagePledge: Signal<ManagePledgeViewParamConfigData, Never>
  public let goToProject: Signal<(Project, RefTag), Never>
  public let goToSurveyResponse: Signal<SurveyResponse, Never>
  public let goToUpdate: Signal<(Project, Update), Never>
  public let showEmptyStateIsLoggedIn: Signal<Bool, Never>
  public let showFindFriendsSection: Signal<(FriendsSource, Bool), Never>
  public let showFacebookConnectSection: Signal<(FriendsSource, Bool), Never>
  public let showFacebookConnectErrorAlert: Signal<AlertError, Never>
  public let unansweredSurveys: Signal<[SurveyResponse], Never>
  public let updateUserInEnvironment: Signal<User, Never>

  public var inputs: ActitiviesViewModelInputs { return self }
  public var outputs: ActivitiesViewModelOutputs { return self }
}
