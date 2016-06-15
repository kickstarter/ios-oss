import KsApi
import Foundation
import ReactiveCocoa
import Result

public protocol ActivityFriendFollowViewModelInputs {
  func activity(activity: Activity)
  func followButtonPressed()
}

public protocol ActivityFriendFollowViewModelOutputs {
  var friendImageURL: Signal<NSURL?, NoError> { get }
  var title: Signal<String, NoError> { get }
  var hideFollowButton: Signal<Bool, NoError> { get }
}

public final class ActivityFriendFollowViewModel: ActivityFriendFollowViewModelInputs,
ActivityFriendFollowViewModelOutputs {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.friendImageURL = activity.map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.title = activity.map {
      Strings.activity_user_name_is_now_following_you(user_name: $0.user?.name ?? "")
    }

    self.hideFollowButton = activity.mapConst(false)
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func activity(activity: Activity) {
    self.activityProperty.value = activity
  }

  private let followPressedProperty = MutableProperty()
  public func followButtonPressed() {
    self.followPressedProperty.value = ()
  }

  public let friendImageURL: Signal<NSURL?, NoError>
  public let title: Signal<String, NoError>
  public let hideFollowButton: Signal<Bool, NoError>

  public var inputs: ActivityFriendFollowViewModelInputs { return self }
  public var outputs: ActivityFriendFollowViewModelOutputs { return self }
}
