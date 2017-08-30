import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result
import Prelude

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
  var cellAccessibilityValue: Signal<String, NoError> { get }

  /// Emits whether Follow button should be enabled
  var enableFollowButton: Signal<Bool, NoError> { get }

  /// Emits whether Unfollow button should be enabled
  var enableUnfollowButton: Signal<Bool, NoError> { get }

  // Emits follow button accessibilityLabel that includes friend's name
  var followButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits when to show Follow button
  var hideFollowButton: Signal<Bool, NoError> { get }

  /// Emits whether should show projects created text
  var hideProjectsCreated: Signal<Bool, NoError> { get }

  /// Emits when to show Unfollow button
  var hideUnfollowButton: Signal<Bool, NoError> { get }

  /// Emits an URL to friend's avatar
  var imageURL: Signal<URL?, NoError> { get }

  /// Emits friend's location
  var location: Signal<String, NoError> { get }

  /// Emits friend's name
  var name: Signal<String, NoError> { get }

  /// Emits number of projects backed text
  var projectsBackedText: Signal<String, NoError> { get }

  /// Emits number of projects created text
  var projectsCreatedText: Signal<String, NoError> { get }

  // Emits unfollow button accessibilityLabel that includes friend's name
  var unfollowButtonAccessibilityLabel: Signal<String, NoError> { get }

}

public protocol FindFriendsFriendFollowCellViewModelType {
  var inputs: FindFriendsFriendFollowCellViewModelInputs { get }
  var outputs: FindFriendsFriendFollowCellViewModelOutputs { get }
}

public final class FindFriendsFriendFollowCellViewModel: FindFriendsFriendFollowCellViewModelType,
  FindFriendsFriendFollowCellViewModelInputs, FindFriendsFriendFollowCellViewModelOutputs {
    public init() {
    let friend = self.configureWithFriendProperty.signal.skipNil()
      .map(cached(friend:))

    self.imageURL = friend.map { URL(string: $0.avatar.medium) }

    self.location = friend.map { $0.location?.displayableName ?? "" }

    self.name = friend.map { $0.name }

    self.projectsBackedText = friend
      .map { $0.stats.backedProjectsCount ?? 0 }
      .map(Strings.social_following_friend_projects_count_backed(backed_count:))

    let projectsCreatedCount = friend.map { $0.stats.createdProjectsCount ?? 0 }
    self.hideProjectsCreated = projectsCreatedCount.map { $0 == 0 }

    self.projectsCreatedText = projectsCreatedCount
      .filter { $0 > 0 }
      .map(Strings.social_following_friend_projects_count_created(created_count:))

    let isLoadingFollowRequest = MutableProperty(false)
    let isLoadingUnfollowRequest = MutableProperty(false)

    let followFriendEvent = friend
      .takeWhen(self.followButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.followFriend(userId: user.id)
          .on(
            starting: {
              isLoadingFollowRequest.value = true
            },
            terminated: {
              isLoadingFollowRequest.value = false
          })
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .mapConst(user |> User.lens.isFriend .~ true)
          .materialize()
    }

    let unfollowFriendEvent = friend
      .takeWhen(self.unfollowButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.unfollowFriend(userId: user.id)
          .on(
            starting: {
              isLoadingUnfollowRequest.value = true
            },
            terminated: {
              isLoadingUnfollowRequest.value = false
          })
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .mapConst(user |> User.lens.isFriend .~ false)
          .materialize()
    }

    let updatedFriendToFollowed = followFriendEvent.values()
      .on(value: { cache(friend: $0, isFriend: true) })

    let updatedFriendToUnfollowed = unfollowFriendEvent.values()
      .on(value: { cache(friend: $0, isFriend: false) })

    let isFollowed = Signal.merge(friend, updatedFriendToFollowed, updatedFriendToUnfollowed)
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

    self.followButtonAccessibilityLabel = name.map(Strings.Follow_friend_name)
    self.unfollowButtonAccessibilityLabel = name.map(Strings.Unfollow_friend_name)
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
    configureWithFriendProperty.value = friend
    configureWithSourceProperty.value = source
  }

  fileprivate let followButtonTappedProperty = MutableProperty()
  public func followButtonTapped() {
    followButtonTappedProperty.value = ()
  }

  fileprivate let unfollowButtonTappedProperty = MutableProperty()
  public func unfollowButtonTapped() {
    unfollowButtonTappedProperty.value = ()
  }

  public let cellAccessibilityValue: Signal<String, NoError>
  public let enableFollowButton: Signal<Bool, NoError>
  public let enableUnfollowButton: Signal<Bool, NoError>
  public let followButtonAccessibilityLabel: Signal<String, NoError>
  public let hideFollowButton: Signal<Bool, NoError>
  public let hideProjectsCreated: Signal<Bool, NoError>
  public let hideUnfollowButton: Signal<Bool, NoError>
  public let imageURL: Signal<URL?, NoError>
  public let location: Signal<String, NoError>
  public let name: Signal<String, NoError>
  public let projectsBackedText: Signal<String, NoError>
  public let projectsCreatedText: Signal<String, NoError>
  public let unfollowButtonAccessibilityLabel: Signal<String, NoError>
}

private func cached(friend: User) -> User {
  if let friendCache = AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] as? [Int:Bool] {
    let isFriend = friendCache[friend.id] ?? friend.isFriend
    return friend |> User.lens.isFriend .~ isFriend
  } else {
    return friend
  }
}

private func cache(friend: User, isFriend: Bool) {
  AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] =
    AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] ?? [Int: Bool]()

  var cache = AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] as? [Int:Bool]
  cache?[friend.id] = isFriend

  AppEnvironment.current.cache[KSCache.ksr_findFriendsFollowing] = cache
}
