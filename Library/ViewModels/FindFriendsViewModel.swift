import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol FindFriendsViewModelInputs {
  /// Call to set where Friends View Controller was loaded from
  func configureWith(source: FriendsSource)

  /// Call when press OK on Follow All Friends confirmation alert
  func confirmFollowAllFriends()

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
  var friends: Signal<([User], FriendsSource), Never> { get }

  /// Emits DiscoveryParams when should go to Discovery
  var goToDiscovery: Signal<DiscoveryParams, Never> { get }

  /// Emits when error alert should show with AlertError
  var showErrorAlert: Signal<AlertError, Never> { get }

  /// Emits bool whether Facebook Connect view should show with the source that presented the controller.
  var showFacebookConnect: Signal<(FriendsSource, Bool), Never> { get }

  /// Emits friends count when should display "Follow all friends" alert.
  var showFollowAllFriendsAlert: Signal<Int, Never> { get }

  /// Emits a boolean that determines if loader is hidden.
  var showLoadingIndicatorView: Signal<Bool, Never> { get }

  /// Emits the current user and the source that presented the controller.
  var stats: Signal<(FriendStatsEnvelope, FriendsSource), Never> { get }
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
    .map { _ in
      FindFriendsFacebookConnectCellViewModel
        .showFacebookConnectionSection(for: AppEnvironment.current.currentUser)
    }

    let requestFirstPageWith = Signal.merge(
      shouldShowFacebookConnect.filter(isFalse).ignoreValues(),
      followAll.ignoreValues().ksr_debounce(.seconds(2), on: AppEnvironment.current.scheduler)
    )

    let requestNextPageWhen = self.willDisplayRowProperty.signal.skipNil()
      .map { row, total in row >= total - 3 && total > 1 }
      .skipRepeats()
      .filter(isTrue)
      .ignoreValues()

    let (friends, isLoading, _, _) = paginate(
      requestFirstPageWith: requestFirstPageWith,
      requestNextPageWhen: requestNextPageWhen,
      clearOnNewRequest: true,
      valuesFromEnvelope: { $0.users },
      cursorFromEnvelope: { $0.urls.api.moreUsers },
      requestFromParams: { AppEnvironment.current.apiService.fetchFriends() },
      requestFromCursor: {
        $0.map { AppEnvironment.current.apiService.fetchFriends(paginationUrl: $0) } ?? .empty
      }
    )

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

    self.showFacebookConnect = shouldShowFacebookConnect.signal
      .map { (.findFriends, $0) }

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
      shouldShowFacebookConnect,
      stats
    ).map(unpack) // unpack into 3-tuple (shouldShowFacebookConnect, friends, source)
      .filter { shouldShowFacebookConnect, _, _ in
        !shouldShowFacebookConnect
      }.map { _, friends, source in
        (friends, source)
      }
  }

  fileprivate let configureWithProperty = MutableProperty<FriendsSource>(FriendsSource.findFriends)
  public func configureWith(source: FriendsSource) {
    self.configureWithProperty.value = source
  }

  fileprivate let confirmFollowAllFriendsProperty = MutableProperty(())
  public func confirmFollowAllFriends() {
    self.confirmFollowAllFriendsProperty.value = ()
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

  public let friends: Signal<([User], FriendsSource), Never>
  public let goToDiscovery: Signal<DiscoveryParams, Never>
  public let showErrorAlert: Signal<AlertError, Never>
  public let showFacebookConnect: Signal<(FriendsSource, Bool), Never>
  public let showFollowAllFriendsAlert: Signal<Int, Never>
  public let showLoadingIndicatorView: Signal<Bool, Never>
  public let stats: Signal<(FriendStatsEnvelope, FriendsSource), Never>

  public var inputs: FindFriendsViewModelInputs { return self }
  public var outputs: FindFriendsViewModelOutputs { return self }
}
