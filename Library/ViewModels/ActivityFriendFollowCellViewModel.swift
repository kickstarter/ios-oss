import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ActivityFriendFollowCellViewModelInputs {
  /// Call to configure activity with Activity.
  func configureWith(activity: Activity)

  /// Call when follow button is tapped.
  func followButtonTapped()
}

public protocol ActivityFriendFollowCellViewModelOutputs {
  /// Emits a URL to the friend image.
  var friendImageURL: Signal<URL?, Never> { get }

  /// Emits whether to hide the follow button.
  var hideFollowButton: Signal<Bool, Never> { get }

  /// Emits text for title label.
  var title: Signal<NSAttributedString, Never> { get }
}

public final class ActivityFriendFollowCellViewModel: ActivityFriendFollowCellViewModelInputs,
  ActivityFriendFollowCellViewModelOutputs {
  public init() {
    let friend = self.activityProperty.signal.skipNil()
      .map(Activity.lens.user.view)
      .skipNil()
      .map(cached(friend:))

    self.friendImageURL = friend.map { URL.init(string: $0.avatar.small) }

    self.title = friend.map {
      let string = Strings.activity_user_name_is_now_following_you(user_name: "<b>\($0.name)</b>")
      return string.simpleHtmlAttributedString(
        base: [
          NSAttributedString.Key.font: UIFont.ksr_subhead(size: 14.0),
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ],
        bold: [
          NSAttributedString.Key.font: UIFont.ksr_headline(size: 14.0),
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ]
      ) ?? NSAttributedString(string: "")
    }

    let followFriendEvent = friend.takeWhen(self.followButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.followFriend(userId: user.id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let followFriendSuccess = followFriendEvent.values()
      .on(value: { cache(friend: $0, isFriend: true) })

    self.hideFollowButton = Signal.merge(friend, followFriendSuccess)
      .map { $0.isFriend ?? false }
      .skipRepeats()
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  fileprivate let followButtonTappedProperty = MutableProperty(())
  public func followButtonTapped() {
    self.followButtonTappedProperty.value = ()
  }

  public let friendImageURL: Signal<URL?, Never>
  public let hideFollowButton: Signal<Bool, Never>
  public let title: Signal<NSAttributedString, Never>

  public var inputs: ActivityFriendFollowCellViewModelInputs { return self }
  public var outputs: ActivityFriendFollowCellViewModelOutputs { return self }
}

private func cached(friend: User) -> User {
  if let friendCache = AppEnvironment.current.cache[KSCache.ksr_activityFriendsFollowing] as? [Int: Bool] {
    let isFriend = friendCache[friend.id] ?? friend.isFriend
    return friend |> \.isFriend .~ isFriend
  } else {
    return friend
  }
}

private func cache(friend: User, isFriend: Bool) {
  AppEnvironment.current.cache[KSCache.ksr_activityFriendsFollowing] =
    AppEnvironment.current.cache[KSCache.ksr_activityFriendsFollowing] ?? [Int: Bool]()

  var cache = AppEnvironment.current.cache[KSCache.ksr_activityFriendsFollowing] as? [Int: Bool]
  cache?[friend.id] = isFriend

  AppEnvironment.current.cache[KSCache.ksr_activityFriendsFollowing] = cache
}
