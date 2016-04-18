import Library
import Models
import Library
import Foundation
import Library
import ReactiveCocoa
import Result

internal protocol ActivityFriendBackingViewModelInputs {
  func activity(activity: Activity)
}

internal protocol ActivityFriendBackingViewModelOutputs {
  var friendImageURL: Signal<NSURL?, NoError> { get }
  var friendTitle: Signal<String, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var projectImageURL: Signal<NSURL?, NoError> { get }
}

internal protocol ActivityFriendBackingViewModelType {
  var inputs: ActivityFriendBackingViewModelInputs { get }
  var outputs: ActivityFriendBackingViewModelOutputs { get }
}

internal final class ActivityFriendBackingViewModel: ActivityFriendBackingViewModelType,
ActivityFriendBackingViewModelInputs, ActivityFriendBackingViewModelOutputs {

  private let activityProperty = MutableProperty<Activity?>(nil)
  internal func activity(activity: Activity) {
    self.activityProperty.value = activity
  }

  internal let friendImageURL: Signal<NSURL?, NoError>
  internal let friendTitle: Signal<String, NoError>
  internal let projectName: Signal<String, NoError>
  internal let projectImageURL: Signal<NSURL?, NoError>
  internal let creatorName: Signal<String, NoError>

  internal var inputs: ActivityFriendBackingViewModelInputs { return self }
  internal var outputs: ActivityFriendBackingViewModelOutputs { return self }

  internal init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.friendImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(NSURL.init) }


    self.friendTitle = activity
      .map { activity in
        localizedString(
          key: "friend.title",
          defaultValue: "%{friend_name} backed a %{category} project.",
          substitutions: [
            "friend_name": activity.user?.name ?? "",
            "category": activity.project?.category.name ?? ""
          ]
        )
    }

    self.projectName = activity.map { $0.project?.name ?? "" }

    self.projectImageURL = activity.map { ($0.project?.photo.med).flatMap(NSURL.init) }

    self.creatorName = activity.map { $0.project?.creator.name ?? "" }
  }
}
