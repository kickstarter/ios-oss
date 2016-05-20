import Models
import Foundation
import ReactiveCocoa
import Result
import Library

internal protocol ActivityFriendFollowViewModelInputs {
  func activity(activity: Activity)
  func followButtonPressed()
}

internal protocol ActivityFriendFollowViewModelOutputs {
  var friendImageURL: Signal<NSURL?, NoError> { get }
  var title: Signal<String, NoError> { get }
  var hideFollowButton: Signal<Bool, NoError> { get }
}

internal final class ActivityFriendFollowViewModel: ActivityFriendFollowViewModelInputs,
ActivityFriendFollowViewModelOutputs {

  internal init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.friendImageURL = activity.map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.title = activity.map {
      localizedString(
        key: "activity.user_name_is_now_following_you",
        defaultValue: "%{user_name} is now following you!",
        substitutions: ["user_name": $0.user?.name ?? ""]
      )
    }

    self.hideFollowButton = activity.mapConst(false)
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  internal func activity(activity: Activity) {
    self.activityProperty.value = activity
  }

  private let followPressedProperty = MutableProperty()
  internal func followButtonPressed() {
    self.followPressedProperty.value = ()
  }

  internal let friendImageURL: Signal<NSURL?, NoError>
  internal let title: Signal<String, NoError>
  internal let hideFollowButton: Signal<Bool, NoError>

  internal var inputs: ActivityFriendFollowViewModelInputs { return self }
  internal var outputs: ActivityFriendFollowViewModelOutputs { return self }
}
