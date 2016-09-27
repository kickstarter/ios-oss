import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol FindFriendsViewModelInputs {
  /// Call to set where Friends View Controller was loaded from
  func configureWith(source source: FriendsSource)

  /// Call when press OK on Follow All Friends confirmation alert
  func confirmFollowAllFriends()

  /// Call when press Cancel on Follow All Friends confirmation alert
  func declineFollowAllFriends()

  /// Call when "Discover projects" button is tapped
  func discoverButtonTapped()

  /// Call when user updates to be Facebook Connected.
  func findFriendsFacebookConnectCellDidFacebookConnectUser()

  /// Call when the Facebook Connect section is dismissed.
  func findFriendsFacebookConnectCellDidDismissHeader()

  /// Call when an alert should be shown.
  func findFriendsFacebookConnectCellShowErrorAlert(alert: AlertError)

  /// Call when should display "Follow all friends?" confirmation alert
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount friendCount: Int)

  /// Call when friend status updates from a FriendFollowCell.
  func updateFriend(updatedFriend: User)

  /// Call when view loads
  func viewDidLoad()

  /// Call when a new row of friends is displayed
  func willDisplayRow(row: Int, outOf totalRows: Int)
}

public protocol FindFriendsViewModelOutputs {
  /// Emits an array of friend users with the source that presented the controller.
  var friends: Signal<([User], FriendsSource), NoError> { get }

  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, NoError> { get }

  /// Emits bool whether friends are loading or not
  var isLoading: Signal<Bool, NoError> { get }

  /// Emits when error alert should show with AlertError
  var showErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits bool whether Facebook Connect view should show with the source that presented the controller.
  var showFacebookConnect: Signal<(FriendsSource, Bool), NoError> { get }

  /// Emits friends count when should display "Follow all friends" alert.
  var showFollowAllFriendsAlert: Signal<Int, NoError> { get }

  /// Emits the current user and the source that presented the controller.
  var stats: Signal<(FriendStatsEnvelope, FriendsSource), NoError> { get }
}

public protocol FindFriendsViewModelType {
  var inputs: FindFriendsViewModelInputs { get }
  var outputs: FindFriendsViewModelOutputs { get }
}

public final class FindFriendsViewModel: FindFriendsViewModelType, FindFriendsViewModelInputs,
  FindFriendsViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let source = self.configureWithProperty.signal

    let followAll = self.confirmFollowAllFriendsProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.followAllFriends()
          .demoteErrors()
      }

    let shouldShowFacebookConnect = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.userFacebookConnectedProperty.signal
      )
      .map { !(AppEnvironment.current.currentUser?.facebookConnected ?? false) }

    let requestFirstPageWith = Signal.merge(
      shouldShowFacebookConnect.filter(isFalse).ignoreValues(),
      followAll.ignoreValues()
    )

    let requestNextPageWhen = self.willDisplayRowProperty.signal.ignoreNil()
      .map { row, total in row >= total - 3 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let friends: Signal<[User], NoError>
    (friends, self.isLoading, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPageWhen,
      clearOnNewRequest: false,
      valuesFromEnvelope: { $0.users },
      cursorFromEnvelope: { $0.urls.api.moreUsers },
      requestFromParams: { AppEnvironment.current.apiService.fetchFriends() },
      requestFromCursor: {
        $0.map { AppEnvironment.current.apiService.fetchFriends(paginationUrl: $0) } ?? .empty
    })

    let friendToUpdate = Signal.merge(
      self.viewDidLoadProperty.signal.take(1).signal.mapConst(nil),
      self.updateFriendProperty.signal
    )

    let updatedFriends = combineLatest(friends, friendToUpdate)
      .map { currentFriends, updatedFriend in
        currentFriends
          .map { friend in
            friend == updatedFriend ? updatedFriend : friend
          }
          .compact()
    }

    self.friends = combineLatest(updatedFriends, source)

    self.goToDiscovery = self.discoverButtonTappedProperty.signal
      .map {
        DiscoveryParams.defaults
          |> DiscoveryParams.lens.social .~ true
          |> DiscoveryParams.lens.sort .~ .magic
    }

    self.showFollowAllFriendsAlert = self.showFollowAllFriendsAlertProperty.signal

    self.showErrorAlert = self.showFacebookConnectErrorAlertProperty.signal.ignoreNil()

    self.showFacebookConnect = combineLatest(source, shouldShowFacebookConnect)

    let statsEvent = shouldShowFacebookConnect
      .filter(isFalse)
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchFriendStats()
        .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
        .materialize()
    }

    self.stats = combineLatest(statsEvent.values(), source)

    source
      .takeWhen(self.viewDidLoadProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackFindFriendsView(source: $0) }

    source
      .takeWhen(self.declineFollowAllFriendsProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackDeclineFriendFollowAll(source: $0) }

    source
      .takeWhen(followAll)
      .observeNext { AppEnvironment.current.koala.trackFriendFollowAll(source: $0) }
  }
  // swiftlint:enable function_body_length

  private let configureWithProperty = MutableProperty<FriendsSource>(FriendsSource.findFriends)
  public func configureWith(source source: FriendsSource) {
    configureWithProperty.value = source
  }
  private let confirmFollowAllFriendsProperty = MutableProperty()
  public func confirmFollowAllFriends() {
    confirmFollowAllFriendsProperty.value = ()
  }
  private let declineFollowAllFriendsProperty = MutableProperty()
  public func declineFollowAllFriends() {
    declineFollowAllFriendsProperty.value = ()
  }
  public func findFriendsFacebookConnectCellDidDismissHeader() {}

  private let userFacebookConnectedProperty = MutableProperty()
  public func findFriendsFacebookConnectCellDidFacebookConnectUser() {
    userFacebookConnectedProperty.value = ()
  }
  private let showFacebookConnectErrorAlertProperty = MutableProperty<AlertError?>(nil)
  public func findFriendsFacebookConnectCellShowErrorAlert(alert: AlertError) {
    showFacebookConnectErrorAlertProperty.value = alert
  }
  private let updateFriendProperty = MutableProperty<User?>(nil)
  public func updateFriend(updatedFriend: User) {
    self.updateFriendProperty.value = updatedFriend
  }
  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    viewDidLoadProperty.value = ()
  }
  private let discoverButtonTappedProperty = MutableProperty()
  public func discoverButtonTapped() {
    discoverButtonTappedProperty.value = ()
  }
  private let showFollowAllFriendsAlertProperty = MutableProperty<Int>(0)
  public func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount friendCount: Int) {
    showFollowAllFriendsAlertProperty.value = friendCount
  }
  private let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let friends: Signal<([User], FriendsSource), NoError>
  public let showFacebookConnect: Signal<(FriendsSource, Bool), NoError>
  public let goToDiscovery: Signal<DiscoveryParams, NoError>
  public let isLoading: Signal<Bool, NoError>
  public let showFollowAllFriendsAlert: Signal<Int, NoError>
  public let stats: Signal<(FriendStatsEnvelope, FriendsSource), NoError>
  public let showErrorAlert: Signal<AlertError, NoError>

  public var inputs: FindFriendsViewModelInputs { return self }
  public var outputs: FindFriendsViewModelOutputs { return self }
}
