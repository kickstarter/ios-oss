import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude

public protocol FindFriendsViewModelInputs {
  /// Call to set where Friends View Controller was loaded from
  func configureWith(source: FriendsSource)

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
  func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError)

  /// Call when should display "Follow all friends?" confirmation alert
  func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: Int)

  /// Call when friend status updates from a FriendFollowCell.
  func updateFriend(_ updatedFriend: User)

  /// Call when view loads
  func viewDidLoad()

  /// Call when a new row of friends is displayed
  func willDisplayRow(_ row: Int, outOf totalRows: Int)
}

public protocol FindFriendsViewModelOutputs {
  /// Emits an array of friend users with the source that presented the controller.
  var friends: Signal<([User], FriendsSource), NoError> { get }

  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, NoError> { get }

  /// Emits when error alert should show with AlertError
  var showErrorAlert: Signal<AlertError, NoError> { get }

  /// Emits bool whether Facebook Connect view should show with the source that presented the controller.
  var showFacebookConnect: Signal<(FriendsSource, Bool), NoError> { get }

  /// Emits bool whether Facebook reconnect view should show with the source that presented the controller.
  var showFacebookReconnect: Signal<(FriendsSource, Bool), NoError> { get }

  /// Emits friends count when should display "Follow all friends" alert.
  var showFollowAllFriendsAlert: Signal<Int, NoError> { get }

  /// Emits a boolean that determines if loader is hidden.
  var showLoadingIndicatorView: Signal<Bool, NoError> { get }

  /// Emits the current user and the source that presented the controller.
  var stats: Signal<(FriendStatsEnvelope, FriendsSource), NoError> { get }
}

public protocol FindFriendsViewModelType {
  var inputs: FindFriendsViewModelInputs { get }
  var outputs: FindFriendsViewModelOutputs { get }
}

public final class FindFriendsViewModel: FindFriendsViewModelType, FindFriendsViewModelInputs,
  FindFriendsViewModelOutputs {

    public init() {
    let source = self.configureWithProperty.signal

    let followAll = self.confirmFollowAllFriendsProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.followAllFriends()
          .on(value: { _ in AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] = [Int: Bool]() })
          .demoteErrors()
      }

    let shouldShowFacebookConnect = Signal.merge(
      self.viewDidLoadProperty.signal,
      self.userFacebookConnectedProperty.signal
      )
      .map { !(AppEnvironment.current.currentUser?.facebookConnected ?? false) }

    let requestFirstPageWith = Signal.merge(
      shouldShowFacebookConnect.filter(isFalse).ignoreValues(),
      followAll.ignoreValues().ksr_debounce(.seconds(2), on: AppEnvironment.current.scheduler)
    )

    let requestNextPageWhen = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in row >= total - 3 && total > 1 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let (friends, isLoading, pageCount) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPageWhen,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.users },
      cursorFromEnvelope: { $0.urls.api.moreUsers },
      requestFromParams: { AppEnvironment.current.apiService.fetchFriends() },
      requestFromCursor: {
        $0.map { AppEnvironment.current.apiService.fetchFriends(paginationUrl: $0) } ?? .empty
    })

    self.friends = Signal.combineLatest(
      Signal.merge(friends, followAll.mapConst([])).skipRepeats(==),
      source
    )

    self.goToDiscovery = self.discoverButtonTappedProperty.signal
      .map {
        DiscoveryParams.defaults
          |> DiscoveryParams.lens.social .~ true
          |> DiscoveryParams.lens.sort .~ .magic
    }

    self.showFollowAllFriendsAlert = self.showFollowAllFriendsAlertProperty.signal

    self.showErrorAlert = self.showFacebookConnectErrorAlertProperty.signal.skipNil()

    self.showFacebookConnect = shouldShowFacebookConnect.map { (.findFriends, $0) }

    let needsReconnect = shouldShowFacebookConnect
      .filter(isFalse)
      .map { _ in AppEnvironment.current.currentUser?.needsFreshFacebookToken ?? false}

    self.showFacebookReconnect = needsReconnect
      .map {
        (.findFriends, $0)
      }

    self.showLoadingIndicatorView = Signal.merge(
      isLoading.take(first: 1),
      friends.mapConst(false)
      ).skipRepeats()

    let statsEvent = shouldShowFacebookConnect
      .filter(isFalse)
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchFriendStats()
        .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
        .materialize()
    }

    let stats = Signal.combineLatest(statsEvent.values(), source)

    self.stats = Signal.combineLatest(
        needsReconnect,
        stats
      ).map(unpack) // unpack into 3-tuple (needsReconnect, friends, source)
      .filter { !$0.0 } // filter for when needsReconnect is false
      .map { ($1, $2)} // map back into expected tuple (friends, source)

    source
      .takeWhen(self.viewDidLoadProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackFindFriendsView(source: $0) }

    source
      .takeWhen(self.declineFollowAllFriendsProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackDeclineFriendFollowAll(source: $0) }

    source
      .takeWhen(followAll)
      .observeValues { AppEnvironment.current.koala.trackFriendFollowAll(source: $0) }

    source
      .takePairWhen(pageCount.skip(first: 1).filter { $0 > 1 })
      .observeValues { AppEnvironment.current.koala.loadedMoreFriends(source: $0, pageCount: $1) }
  }

  fileprivate let configureWithProperty = MutableProperty<FriendsSource>(FriendsSource.findFriends)
  public func configureWith(source: FriendsSource) {
    self.configureWithProperty.value = source
  }
  fileprivate let confirmFollowAllFriendsProperty = MutableProperty(())
  public func confirmFollowAllFriends() {
    self.confirmFollowAllFriendsProperty.value = ()
  }
  fileprivate let declineFollowAllFriendsProperty = MutableProperty(())
  public func declineFollowAllFriends() {
    self.declineFollowAllFriendsProperty.value = ()
  }
  public func findFriendsFacebookConnectCellDidDismissHeader() {}

  fileprivate let userFacebookConnectedProperty = MutableProperty(())
  public func findFriendsFacebookConnectCellDidFacebookConnectUser() {
    self.userFacebookConnectedProperty.value = ()
  }
  fileprivate let showFacebookConnectErrorAlertProperty = MutableProperty<AlertError?>(nil)
  public func findFriendsFacebookConnectCellShowErrorAlert(_ alert: AlertError) {
    self.showFacebookConnectErrorAlertProperty.value = alert
  }
  fileprivate let updateFriendProperty = MutableProperty<User?>(nil)
  public func updateFriend(_ updatedFriend: User) {
    self.updateFriendProperty.value = updatedFriend
  }
  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }
  fileprivate let discoverButtonTappedProperty = MutableProperty(())
  public func discoverButtonTapped() {
    self.discoverButtonTappedProperty.value = ()
  }
  fileprivate let showFollowAllFriendsAlertProperty = MutableProperty<Int>(0)
  public func findFriendsStatsCellShowFollowAllFriendsAlert(friendCount: Int) {
    self.showFollowAllFriendsAlertProperty.value = friendCount
  }
  fileprivate let willDisplayRowProperty = MutableProperty<(row: Int, total: Int)?>(nil)
  public func willDisplayRow(_ row: Int, outOf totalRows: Int) {
    self.willDisplayRowProperty.value = (row, totalRows)
  }

  public let friends: Signal<([User], FriendsSource), NoError>
  public let goToDiscovery: Signal<DiscoveryParams, NoError>
  public let showErrorAlert: Signal<AlertError, NoError>
  public let showFacebookConnect: Signal<(FriendsSource, Bool), NoError>
  public let showFacebookReconnect: Signal<(FriendsSource, Bool), NoError>
  public let showFollowAllFriendsAlert: Signal<Int, NoError>
  public let showLoadingIndicatorView: Signal<Bool, NoError>
  public let stats: Signal<(FriendStatsEnvelope, FriendsSource), NoError>

  public var inputs: FindFriendsViewModelInputs { return self }
  public var outputs: FindFriendsViewModelOutputs { return self }
}
