import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ActivityFriendFollowCellViewModelInputs {
  /// Call to configure activity with Activity.
  func configureWith(activity activity: Activity)

  /// Call when follow button is tapped.
  func followButtonTapped()
}

public protocol ActivityFriendFollowCellViewModelOutputs {
  /// Emits a NSURL to the friend image.
  var friendImageURL: Signal<NSURL?, NoError> { get }

  /// Emits whether to hide the follow button.
  var hideFollowButton: Signal<Bool, NoError> { get }

  /// Emits text for title label.
  var title: Signal<NSAttributedString, NoError> { get }
}

public final class ActivityFriendFollowCellViewModel: ActivityFriendFollowCellViewModelInputs,
ActivityFriendFollowCellViewModelOutputs {

  public init() {
    let friend = self.activityProperty.signal.ignoreNil()
      .map(Activity.lens.user.view)
      .ignoreNil()
      .map(cached(friend:))

    self.friendImageURL = friend.map { NSURL.init(string: $0.avatar.small) }

    self.title = friend.map {
      let string = Strings.activity_user_name_is_now_following_you(user_name: "<b>\($0.name ?? "")</b>")
      return string.simpleHtmlAttributedString(base: [
        NSFontAttributeName: UIFont.ksr_subhead(size: 14.0),
        NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
        ],
        bold: [
          NSFontAttributeName: UIFont.ksr_headline(size: 14.0),
          NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
        ]) ?? NSAttributedString(string: "")
    }

    let followFriendEvent = friend.takeWhen(self.followButtonTappedProperty.signal)
      .switchMap { user in
        AppEnvironment.current.apiService.followFriend(userId: user.id)
        .delay(AppEnvironment.current.apiDelayInterval, onScheduler: AppEnvironment.current.scheduler)
        .materialize()
    }

    let followFriendSuccess = followFriendEvent.values()
      .on(next: { cache(friend: $0, isFriend: true) })

    self.hideFollowButton = Signal.merge(friend, followFriendSuccess)
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
  public let hideFollowButton: Signal<Bool, NoError>
  public let title: Signal<NSAttributedString, NoError>

  public var inputs: ActivityFriendFollowCellViewModelInputs { return self }
  public var outputs: ActivityFriendFollowCellViewModelOutputs { return self }
}

internal let activityFriendFollowCacheKey: String = "activity_friend_follow_view_model"

private func cached(friend friend: User) -> User {
  if let friendCache = AppEnvironment.current.cache[activityFriendFollowCacheKey] as? [Int:Bool] {
    let isFriend = friendCache[friend.id] ?? friend.isFriend
    return friend |> User.lens.isFriend .~ isFriend
  } else {
    return friend
  }
}

private func cache(friend friend: User, isFriend: Bool) {
  AppEnvironment.current.cache[activityFriendFollowCacheKey] =
    AppEnvironment.current.cache[activityFriendFollowCacheKey] ?? [Int:Bool]()

  var cache = AppEnvironment.current.cache[activityFriendFollowCacheKey] as? [Int:Bool]
  cache?[friend.id] = isFriend

  AppEnvironment.current.cache[activityFriendFollowCacheKey] = cache
}
