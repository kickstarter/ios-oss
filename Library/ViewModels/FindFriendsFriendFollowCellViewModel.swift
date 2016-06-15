import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result
import Prelude

public protocol FindFriendsFriendFollowCellViewModelInputs {
  /// Call to set friend and source from whence it comes
  func configureWith(friend friend: User, source: FriendsSource)

  /// Call when follow friend button is tapped
  func followButtonTapped()

  /// Call when unfollow friend button is tapped
  func unfollowButtonTapped()
}

public protocol FindFriendsFriendFollowCellViewModelOutputs {
  /// Emits whether Follow button should be enabled
  var enableFollowButton: Signal<Bool, NoError> { get }

  /// Emits whether Unfollow button should be enabled
  var enableUnfollowButton: Signal<Bool, NoError> { get }

  /// Emits when to show Follow button
  var hideFollowButton: Signal<Bool, NoError> { get }

  /// Emits whether should show projects created text
  var hideProjectsCreated: Signal<Bool, NoError> { get }

  /// Emits when to show Unfollow button
  var hideUnfollowButton: Signal<Bool, NoError> { get }

  /// Emits an NSURL to friend's avatar
  var imageURL: Signal<NSURL?, NoError> { get }

  /// Emits friend's location
  var location: Signal<String, NoError> { get }

  /// Emits friend's name
  var name: Signal<String, NoError> { get }

  /// Emits number of projects backed text
  var projectsBackedText: Signal<String, NoError> { get }

  /// Emits number of projects created text
  var projectsCreatedText: Signal<String, NoError> { get }
}

public protocol FindFriendsFriendFollowCellViewModelType {
  var inputs: FindFriendsFriendFollowCellViewModelInputs { get }
  var outputs: FindFriendsFriendFollowCellViewModelOutputs { get }
}

public final class FindFriendsFriendFollowCellViewModel: FindFriendsFriendFollowCellViewModelType,
  FindFriendsFriendFollowCellViewModelInputs, FindFriendsFriendFollowCellViewModelOutputs {
  // swiftlint:disable function_body_length
  public init() {
    let friend = self.configureWithFriendProperty.signal
      .ignoreNil()
      .map(cached(friend:))

    self.imageURL = friend.map { NSURL.init(string: $0.avatar.medium) }

    self.location = friend.map { $0.location?.displayableName ?? "" }

    self.name = friend.map { $0.name }

    self.projectsBackedText = friend
      .map { $0.stats.backedProjectsCount ?? 0 }
      .map { localizedString(
        key: "social_following.friend.projects_count_backed",
        defaultValue: "%{backed_count} backed",
        count: $0,
        substitutions: ["backed_count": "\($0)"]
      )
    }

    self.hideProjectsCreated = friend.map { $0.stats.createdProjectsCount == 0 }

    self.projectsCreatedText = friend
      .filter { $0.stats.createdProjectsCount > 0 }
      .map { $0.stats.createdProjectsCount ?? 0 }
      .map { localizedString(
        key: "social_following.friend.projects_count_created",
        defaultValue: "%{created_count} created",
        count: $0,
        substitutions: ["created_count": "\($0)"]
      )
    }

    let isLoadingFollowRequest = MutableProperty(false)
    let isLoadingUnfollowRequest = MutableProperty(false)

    let followFriendEvent = friend
      .takeWhen(self.followButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.followFriend(userId: user.id)
          .on(
            started: {
              isLoadingFollowRequest.value = true
            },
            terminated: {
              isLoadingFollowRequest.value = false
          })
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }

    let unfollowFriendEvent = friend
      .takeWhen(self.unfollowButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.unfollowFriend(userId: user.id)
          .on(
            started: {
              isLoadingUnfollowRequest.value = true
            },
            terminated: {
              isLoadingUnfollowRequest.value = false
          })
          .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
          .materialize()
    }

    let updatedFriendToFollowed = followFriendEvent
      .values()
      .on(next: { cache(friend: $0, isFriend: true) })

    let updatedFriendToUnfollowed = friend
      .takeWhen(unfollowFriendEvent.values())
      .map(User.lens.isFriend .~ false)
      .on(next: { cache(friend: $0, isFriend: false) })

    let friendStatusChanged = Signal.merge(friend, updatedFriendToFollowed, updatedFriendToUnfollowed)

    let isFollowed = friendStatusChanged.map { $0.isFriend ?? false }

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

    let source = self.configureWithSourceProperty.signal.ignoreNil().map { $0 }

    source
      .takeWhen(self.followButtonTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackFriendFollow(source: $0) }

    source
      .takeWhen(self.unfollowButtonTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackFriendUnfollow(source: $0) }
  }
  // swiftlint:enable function_body_length

  public var inputs: FindFriendsFriendFollowCellViewModelInputs { return self }
  public var outputs: FindFriendsFriendFollowCellViewModelOutputs { return self }

  private let configureWithFriendProperty = MutableProperty<User?>(nil)
  private let configureWithSourceProperty = MutableProperty<FriendsSource?>(nil)
  public func configureWith(friend friend: User, source: FriendsSource) {
    configureWithFriendProperty.value = friend
    configureWithSourceProperty.value = source
  }

  private let followButtonTappedProperty = MutableProperty()
  public func followButtonTapped() {
    followButtonTappedProperty.value = ()
  }

  private let unfollowButtonTappedProperty = MutableProperty()
  public func unfollowButtonTapped() {
    unfollowButtonTappedProperty.value = ()
  }

  public let enableFollowButton: Signal<Bool, NoError>
  public let enableUnfollowButton: Signal<Bool, NoError>
  public let hideFollowButton: Signal<Bool, NoError>
  public let hideUnfollowButton: Signal<Bool, NoError>
  public let imageURL: Signal<NSURL?, NoError>
  public let location: Signal<String, NoError>
  public let name: Signal<String, NoError>
  public let projectsBackedText: Signal<String, NoError>
  public let projectsCreatedText: Signal<String, NoError>
  public let hideProjectsCreated: Signal<Bool, NoError>
}

private func cacheKey(forFriend friend: User) -> String {
  return "find_friends_follow_view_model_friend_\(friend.id)"
}

private func cached(friend friend: User) -> User {
  let key = cacheKey(forFriend: friend)
  let isFriend = AppEnvironment.current.cache[key] as? Bool
  return friend |> User.lens.isFriend .~ (isFriend ?? friend.isFriend)
}

private func cache(friend friend: User, isFriend: Bool) {
  let key = cacheKey(forFriend: friend)
  AppEnvironment.current.cache[key] = isFriend
}
