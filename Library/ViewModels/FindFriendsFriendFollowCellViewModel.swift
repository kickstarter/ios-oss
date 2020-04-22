import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol FindFriendsFriendFollowCellViewModelInputs {
  /// Call to set friend and source from whence it comes
  func configureWith(friend: User, source: FriendsSource)

  /// Call when follow friend button is tapped
  func followButtonTapped()

  /// Call when unfollow friend button is tapped
  func unfollowButtonTapped()
}

public protocol FindFriendsFriendFollowCellViewModelOutputs {
  /// Emits accessibilityValue for the Cell
  var cellAccessibilityValue: Signal<String, Never> { get }

  /// Emits whether Follow button should be enabled
  var enableFollowButton: Signal<Bool, Never> { get }

  /// Emits whether Unfollow button should be enabled
  var enableUnfollowButton: Signal<Bool, Never> { get }

  // Emits follow button accessibilityLabel that includes friend's name
  var followButtonAccessibilityLabel: Signal<String, Never> { get }

  /// Emits when to show Follow button
  var hideFollowButton: Signal<Bool, Never> { get }

  /// Emits whether should show projects created text
  var hideProjectsCreated: Signal<Bool, Never> { get }

  /// Emits when to show Unfollow button
  var hideUnfollowButton: Signal<Bool, Never> { get }

  /// Emits an URL to friend's avatar
  var imageURL: Signal<URL?, Never> { get }

  /// Emits friend's location
  var location: Signal<String, Never> { get }

  /// Emits friend's name
  var name: Signal<String, Never> { get }

  /// Emits number of projects backed text
  var projectsBackedText: Signal<String, Never> { get }

  /// Emits number of projects created text
  var projectsCreatedText: Signal<String, Never> { get }

  // Emits unfollow button accessibilityLabel that includes friend's name
  var unfollowButtonAccessibilityLabel: Signal<String, Never> { get }
}

public protocol FindFriendsFriendFollowCellViewModelType {
  var inputs: FindFriendsFriendFollowCellViewModelInputs { get }
  var outputs: FindFriendsFriendFollowCellViewModelOutputs { get }
}

public final class FindFriendsFriendFollowCellViewModel: FindFriendsFriendFollowCellViewModelType,
  FindFriendsFriendFollowCellViewModelInputs, FindFriendsFriendFollowCellViewModelOutputs {
  public init() {
    let friend: Signal<User, Never> = self.configureWithFriendProperty.signal.skipNil()
      .map(cached(friend:))

    self.imageURL = friend.map { (friend: User) -> URL? in URL(string: friend.avatar.medium) }

    self.location = friend.map { (friend: User) -> String in friend.location?.displayableName ?? "" }

    self.name = friend.map { (friend: User) -> String in friend.name }

    self.projectsBackedText = friend
      .map { (friend: User) -> Int in friend.stats.backedProjectsCount ?? 0 }
      .map(Strings.social_following_friend_projects_count_backed(backed_count:))

    let projectsCreatedCount: Signal<Int, Never> = friend.map { (friend: User) -> Int in
      friend.stats.createdProjectsCount ?? 0
    }

    self.hideProjectsCreated = projectsCreatedCount.map {
      (count: Int) -> Bool in count == 0
    }

    self.projectsCreatedText = projectsCreatedCount
      .filter { $0 > 0 }
      .map(Strings.social_following_friend_projects_count_created(created_count:))

    let isLoadingFollowRequest: MutableProperty<Bool> = MutableProperty(false)
    let isLoadingUnfollowRequest: MutableProperty<Bool> = MutableProperty(false)

    let followFriendEvent: Signal<Signal<User, ErrorEnvelope>.Event, Never> = friend
      .takeWhen(self.followButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.followFriend(userId: user.id)
          .on(
            starting: {
              isLoadingFollowRequest.value = true
            },
            terminated: {
              isLoadingFollowRequest.value = false
            }
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .mapConst(user |> \.isFriend .~ true)
          .materialize()
      }

    let unfollowFriendEvent: Signal<Signal<User, ErrorEnvelope>.Event, Never> = friend
      .takeWhen(self.unfollowButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.unfollowFriend(userId: user.id)
          .on(
            starting: {
              isLoadingUnfollowRequest.value = true
            },
            terminated: {
              isLoadingUnfollowRequest.value = false
            }
          )
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .mapConst(user |> \.isFriend .~ false)
          .materialize()
      }

    let updatedFriendToFollowed: Signal<User, Never> = followFriendEvent.values()
      .on(value: { (friend: User) -> Void in cache(friend: friend, isFriend: true) })

    let updatedFriendToUnfollowed: Signal<User, Never> = unfollowFriendEvent.values()
      .on(value: { (friend: User) -> Void in cache(friend: friend, isFriend: false) })

    let isFollowed: Signal<Bool, Never> = Signal.merge(
      friend, updatedFriendToFollowed, updatedFriendToUnfollowed
    )
    .map { $0.isFriend ?? false }

    self.hideFollowButton = isFollowed.skipRepeats()

    self.hideUnfollowButton = isFollowed.map(negate).skipRepeats()

    self.enableFollowButton = Signal.merge(
      self.hideFollowButton.map(negate),
      isLoadingFollowRequest.signal.map(negate)
    )
    .skipRepeats()

    self.enableUnfollowButton = Signal.merge(
      self.hideUnfollowButton.map(negate),
      isLoadingUnfollowRequest.signal.map(negate)
    )
    .skipRepeats()

    self.followButtonAccessibilityLabel = self.name.map(Strings.Follow_friend_name)
    self.unfollowButtonAccessibilityLabel = self.name.map(Strings.Unfollow_friend_name)
    self.cellAccessibilityValue = isFollowed.map { $0 ? Strings.Followed() : Strings.Not_followed() }

    let source = self.configureWithSourceProperty.signal.skipNil().map { $0 }

    source
      .takeWhen(self.followButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackFriendFollow(source: $0) }

    source
      .takeWhen(self.unfollowButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackFriendUnfollow(source: $0) }
  }

  public var inputs: FindFriendsFriendFollowCellViewModelInputs { return self }
  public var outputs: FindFriendsFriendFollowCellViewModelOutputs { return self }

  fileprivate let configureWithFriendProperty = MutableProperty<User?>(nil)
  fileprivate let configureWithSourceProperty = MutableProperty<FriendsSource?>(nil)
  public func configureWith(friend: User, source: FriendsSource) {
    self.configureWithFriendProperty.value = friend
    self.configureWithSourceProperty.value = source
  }

  fileprivate let followButtonTappedProperty = MutableProperty(())
  public func followButtonTapped() {
    self.followButtonTappedProperty.value = ()
  }

  fileprivate let unfollowButtonTappedProperty = MutableProperty(())
  public func unfollowButtonTapped() {
    self.unfollowButtonTappedProperty.value = ()
  }

  public let cellAccessibilityValue: Signal<String, Never>
  public let enableFollowButton: Signal<Bool, Never>
  public let enableUnfollowButton: Signal<Bool, Never>
  public let followButtonAccessibilityLabel: Signal<String, Never>
  public let hideFollowButton: Signal<Bool, Never>
  public let hideProjectsCreated: Signal<Bool, Never>
  public let hideUnfollowButton: Signal<Bool, Never>
  public let imageURL: Signal<URL?, Never>
  public let location: Signal<String, Never>
  public let name: Signal<String, Never>
  public let projectsBackedText: Signal<String, Never>
  public let projectsCreatedText: Signal<String, Never>
  public let unfollowButtonAccessibilityLabel: Signal<String, Never>
}

private func cached(friend: User) -> User {
  if let friendCache = AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] as? [Int: Bool] {
    let isFriend = friendCache[friend.id] ?? friend.isFriend
    return friend |> \.isFriend .~ isFriend
  } else {
    return friend
  }
}

private func cache(friend: User, isFriend: Bool) {
  AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] =
    AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] ?? [Int: Bool]()

  var cache = AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] as? [Int: Bool]
  cache?[friend.id] = isFriend

  AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] = cache
}
