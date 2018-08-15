import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ActitiviesViewModelInputs {
  /// Called when the project image in an update activity cell is tapped.
  func activityUpdateCellTappedProjectImage(activity: Activity)

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
  /// Emits an array of activities that should be displayed
  var activities: Signal<[Activity], NoError> { get }

  /// Emits when should remove Facebook Connect section
  var deleteFacebookConnectSection: Signal<(), NoError> { get }

  /// Emits when should remove Find Friends section.
  var deleteFindFriendsSection: Signal<(), NoError> { get }

  /// Emits when we should dismiss the empty state controller.
  var hideEmptyState: Signal<(), NoError> { get }

  /// Emits when should transition to Friends view with source (.Activity).
  var goToFriends: Signal<FriendsSource, NoError> { get }

  /// Emits a project and ref tag that should be used to present a project controller.
  var goToProject: Signal<(Project, RefTag), NoError> { get }

  /// Emits a survey response when we should navigate to the survey to fill it out.
  var goToSurveyResponse: Signal<SurveyResponse, NoError> { get }

  /// Emits a project and update when we should navigate to that update.
  var goToUpdate: Signal<(Project, Update), NoError> { get }

  /// Emits a boolean that indicates if the activities are refreshing.
  var isRefreshing: Signal<Bool, NoError> { get }

  /// Emits `true` when logged-in, `false` when logged-out, when we should show the empty state controller.
  var showEmptyStateIsLoggedIn: Signal<Bool, NoError> { get }

  /// Emits an AlertError to be displayed.
  var showFacebookConnectErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits whether Facebook Connect header cell should show with the .Activity source.
  var showFacebookConnectSection: Signal<(FriendsSource, Bool), NoError> { get }

  /// Emits whether Find Friends header cell should show with the .Activity source.
  var showFindFriendsSection: Signal<(FriendsSource, Bool), NoError> { get }

  /// Emits a non-`nil` survey response if there is an unanswered one available, and `nil` otherwise.
  var unansweredSurveys: Signal<[SurveyResponse], NoError> { get }
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

    let activityToUpdate: Signal<Activity?, NoError> = self.viewWillAppearProperty.signal.skipNil()
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

    let currentUser = Signal
      .merge(
        self.viewDidLoadProperty.signal,
        self.userSessionStartedProperty.signal,
        self.userSessionEndedProperty.signal
      )
      .map { AppEnvironment.current.currentUser }

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

    let surveyValuesOrErrors = Signal.merge(surveyEvents.values().ignoreValues(),
                                            surveyEvents.errors().ignoreValues())

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
      .map { (
        .activity,
        FindFriendsFacebookConnectCellViewModel
          .showFacebookConnectionSection(for: AppEnvironment.current.currentUser) &&
        !AppEnvironment.current.userDefaults.hasClosedFacebookConnectInActivity)
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
      .flatMap { (project, update) -> SignalProducer<(Project, Update), NoError> in
        guard let project = project, let update = update else { return .empty }
        return SignalProducer(value: (project, update))
      }

    self.viewWillAppearProperty.signal
      .skipNil()
      .filter(isFalse)
      .observeValues { _ in AppEnvironment.current.koala.trackActivities() }

    self.refreshProperty.signal
      .observeValues { AppEnvironment.current.koala.trackLoadedNewerActivity() }

    pageCount
      .filter { $0 > 1 }
      .observeValues { AppEnvironment.current.koala.trackLoadedOlderActivity(page: $0) }
  }

  fileprivate let dismissFacebookConnectSectionProperty = MutableProperty(())
  public func findFriendsFacebookConnectCellDidDismissHeader() {
    dismissFacebookConnectSectionProperty.value = ()
  }
  fileprivate let dismissFindFriendsSectionProperty = MutableProperty(())
  public func findFriendsHeaderCellDismissHeader() {
    dismissFindFriendsSectionProperty.value = ()
  }
  fileprivate let goToFriendsProperty = MutableProperty(())
  public func findFriendsHeaderCellGoToFriends() {
    goToFriendsProperty.value = ()
  }
  fileprivate let showFacebookConnectErrorAlertProperty = MutableProperty<AlertError?>(nil)
  public func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError) {
    showFacebookConnectErrorAlertProperty.value = alert
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
    userFacebookConnectedProperty.value = ()
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

  public let activities: Signal<[Activity], NoError>
  public let deleteFacebookConnectSection: Signal<(), NoError>
  public let deleteFindFriendsSection: Signal<(), NoError>
  public let hideEmptyState: Signal<(), NoError>
  public let isRefreshing: Signal<Bool, NoError>
  public let goToFriends: Signal<FriendsSource, NoError>
  public let goToProject: Signal<(Project, RefTag), NoError>
  public let goToSurveyResponse: Signal<SurveyResponse, NoError>
  public let goToUpdate: Signal<(Project, Update), NoError>
  public let showEmptyStateIsLoggedIn: Signal<Bool, NoError>
  public let showFindFriendsSection: Signal<(FriendsSource, Bool), NoError>
  public let showFacebookConnectSection: Signal<(FriendsSource, Bool), NoError>
  public let showFacebookConnectErrorAlert: Signal<AlertError, NoError>
  public let unansweredSurveys: Signal<[SurveyResponse], NoError>

  public var inputs: ActitiviesViewModelInputs { return self }
  public var outputs: ActivitiesViewModelOutputs { return self }
}
