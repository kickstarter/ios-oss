import KsApi
import Foundation
import ReactiveCocoa
import Result
import Prelude

public protocol ActivityFriendFollowCellViewModelInputs {
  func configureWith(activity activity: Activity)
  func followButtonTapped()
}

public protocol ActivityFriendFollowCellViewModelOutputs {
  var friendImageURL: Signal<NSURL?, NoError> { get }
  var hideFollowButton: Signal<Bool, NoError> { get }
  var title: Signal<String, NoError> { get }
}

public final class ActivityFriendFollowCellViewModel: ActivityFriendFollowCellViewModelInputs,
ActivityFriendFollowCellViewModelOutputs {

  public init() {
    let friend = self.activityProperty.signal.ignoreNil()
      .map(Activity.lens.user.view)
      .ignoreNil()
      .map(cached(friend:))

    self.friendImageURL = friend.map { NSURL.init(string: $0.avatar.medium) }

    self.title = friend.map {
      Strings.activity_user_name_is_now_following_you(user_name: $0.name ?? "")
    }

    let followFriendEvent = friend.takeWhen(self.followButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.followFriend(userId: user.id)
        .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
        .materialize()
    }

    let updatedFriendToFollowed = followFriendEvent
      .values()
      .on(next: cache(friend:))

    let friendStatusChanged = Signal.merge(friend, updatedFriendToFollowed)

    self.hideFollowButton = friendStatusChanged
      .map { $0.isFriend ?? false }
      .skipRepeats()

    self.followButtonTappedProperty.signal
      .observeNext { AppEnvironment.current.koala.trackFriendFollow(source: FriendsSource.activity) }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  private let followButtonTappedProperty = MutableProperty()
  public func followButtonTapped() {
    self.followButtonTappedProperty.value = ()
  }

  public let friendImageURL: Signal<NSURL?, NoError>
  public let title: Signal<String, NoError>
  public let hideFollowButton: Signal<Bool, NoError>

  public var inputs: ActivityFriendFollowCellViewModelInputs { return self }
  public var outputs: ActivityFriendFollowCellViewModelOutputs { return self }
}

private func cacheKey(forFriend friend: User) -> String {
  return "activities_friend_follow_view_model_friend_\(friend.id)"
}

private func cached(friend friend: User) -> User {
  let key = cacheKey(forFriend: friend)
  let isFriend = AppEnvironment.current.cache[key] as? Bool
  return friend |> User.lens.isFriend .~ (isFriend ?? friend.isFriend)
}

private func cache(friend friend: User) {
  let key = cacheKey(forFriend: friend)
  AppEnvironment.current.cache[key] = true
}
